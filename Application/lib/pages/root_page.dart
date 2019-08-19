import 'package:flutter/material.dart';
import 'package:gps_tracer/pages/auth/login_page.dart';
import 'package:gps_tracer/pages/home/home_page.dart';
import 'package:gps_tracer/store/secured_storage.dart';
import 'package:gps_tracer/network/network_utils.dart';
import 'dart:async';
import 'package:gps_tracer/store/shared_pref.dart' as shared_pref;
import 'package:gps_tracer/store/file_manager.dart' as file_manager;
import 'package:gps_tracer/models/coordinates.dart';
import 'package:latlong/latlong.dart';
import 'package:gps_tracer/models/trajectory.dart';
import 'dart:convert';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

/// For pretty json formatting
JsonEncoder encoder = new JsonEncoder.withIndent("     ");


/// --------------------------------------------------------------------------
///                         Configuration for background
///                         *****************************
/// --------------------------------------------------------------------------

/// Improvement: fetching the config from the server would be awesome. Would allow to change configurations of people remotely.
final Map<String, dynamic> DEFAULT_CONFIG = {"stayPointGeoRadius":100, "durationStayPoint":20,"distanceFilter":30.0,
  "enableHeadless":false, "foregroundService": false, "stopOnTerminate":true,
  "startOnBoot":false, "debug": true, "reset":true,
  "forceReloadOnLocationChange":false, "allowIdenticalLocations":false,
  "notificationChannelName": "Ma notification channel",
  "notificationText": "",
  "notificationTitle": "Covoit Uliege Dev App",
  "notificationColor": "#0ef596", "stopTimeout":5, "maxRecordsToPersist":1
  , "persitMode":1, "connectivityChangeFlush":true, "disableElasticity":false}; //bg.Config.PERSIST_MODE_LOCATION==1 . bg.Config.PERSIST_MODE_NONE == 0



/// Root page act as an intermediate widget between the login and the home screen
class RootPage extends StatefulWidget{

  RootPage();

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

/// Used to root to home or login according to the user status
enum AuthStatus{
  notLoggedIn,
  loggedIn
}

/// Most important widget of the app. It is initialized by main().
/// If the user is not logged in, this page root to the login page.
/// Upon receiving a valid connection status, this page is called back to root to home page. At the same time, it launches the background process and control its logic.
class _RootPageState extends State<RootPage> {

  // By default, the app root to the login form.
  AuthStatus authStatus = AuthStatus.notLoggedIn;

  Coordinates _endStayPointCandidate;

  bool _activeTrackingEnabled;

  Map<String, dynamic> CONFIG;


  _RootPageState();

  @override
  void initState(){
    super.initState();
    setState(() {
      // If we want to make the connect persistent, change this, so that it does not return
      // always false but check session in memory with a token with limitied lifetime
      // (expiration associated with possibility to extend it if app is still being used)
      authStatus = NetworkUtilsSingleton.getInstance().isLoggedIn()?AuthStatus.loggedIn:AuthStatus.notLoggedIn;
    });
  }

  /// Call this when you get the callback of login_page and user signed in
  void _signedIn() async{

    /* print()'s have not been deleted to act as a documentation */

    bool localizationActivated;
    try {
      localizationActivated =
      await shared_pref.Settings.getSwitchValue("LocationON", true);
    }
    catch(e){
      // by default, enable it
      localizationActivated = true;
    }

    // Get remote configuration of the app from the server
    ServerReply configReply = await NetworkUtilsSingleton.getInstance().getInitConfig();
    if (configReply.isSuccess()) {
      CONFIG = json.decode(configReply.content);
    }
    else{
      CONFIG = DEFAULT_CONFIG;
      print("Error downloading config from server -> default set\n\n${configReply.content}");
    }


    await _configBckgrnd();

    bg.State state = await bg.BackgroundGeolocation.state;
    print("[root_page/signedIn] BackgroundGeolocation configured");
    if (localizationActivated && !state.enabled){
      print("[root_page/signedIn] Calling initBackgrnd()");
      await _initBackground();
      print("[root_page/signedIn] End of Calling initBackgrnd(), starting BackgroundGeolocation now");
      await bg.BackgroundGeolocation.start();
    }
    else if(localizationActivated && state.enabled){
      print("[root_page/signedIn] calling initBackground() without starting it");
      await _initBackground();
    }
    else if (!localizationActivated && state.enabled){
      bg.BackgroundGeolocation.stop();
    }

    setState((){
      print("[root_page] Root to home");
      authStatus = AuthStatus.loggedIn;
    });
  }

  void _signedOut(){
    NetworkUtilsSingleton.getInstance().logout();
    SecuredStorageSingleton.getInstance().deleteAll();
    setState((){
      authStatus = AuthStatus.notLoggedIn;
    });
  }

  /// --------------------------------------------------------------------------
  ///                         Background management methods
  ///                         *****************************
  /// --------------------------------------------------------------------------

  Future<void> _initBackground() async {
    /* print()'s have not been deleted to act as a documentation */

    print("[constructor] Inside initBckgrnd");

    Distance distance = new Distance(); // "Vincenty" algorithm, default to round to integer

    // Put it here and not below, otherwise, getting current position will affect the coordinate list stored on the device.
    // Indeed, endStayPointCandidate is null and afterwards, points are discarded because within geofence.
    _activeTrackingEnabled = false;
    print("[constructor] Set active tracking to false");

    bg.BackgroundGeolocation.getCurrentPosition(
        persist: false,     // <-- do not persist this location
        desiredAccuracy: 0, // <-- desire best possible accuracy
        timeout: 20000,     // <-- wait 20s before giving up.
        samples: 3          // <-- sample 3 location before selecting best
    ).then((bg.Location location) {

      print("[constructor] got location");
      Coordinates thisLocation = Coordinates( location.coords.latitude, location.coords.longitude, DateTime.now(), location.activity.type);
      file_manager.GeofenceStorageSingleton.getInstance().readCurrGeofence().then((String geofence){
        print("[constructor] read currGeofence in memory");
        if(geofence == null || geofence == ""){
          // very first time
          print("[constructor] No geofence on device");
          file_manager.GeofenceStorageSingleton.getInstance().storeGeofence(json.encode(thisLocation));
          print("[constructor] New geofence stored");
          _endStayPointCandidate = thisLocation;
        }
        else{
          print("[constructor] There was a geofence stored on the device");

          Coordinates currGeofence = Coordinates.fromJson(json.decode(geofence));

          double meter = distance(
              new LatLng(location.coords.latitude, location.coords.longitude),
              new LatLng(currGeofence.latitude, currGeofence.longitude)
          );
          if(!_withinGeofence(meter)) {
            print("[constructor] New point is outside the stored geofence");
            _readCoordinatesListFromDevice().then((CoordinatesList coordList) {
              if(coordList != null){
                _flushToServerIfPossibleOtherwiseStoreLocally(thisLocation, coordList).then((void dontCare){
                  file_manager.GeofenceStorageSingleton.getInstance()
                      .replaceGeofence(json.encode(thisLocation));
                  _endStayPointCandidate = thisLocation;

                });
              }
              else{
                print("[Constructor] No coordlist to flush, simply register geofence at current location");
                file_manager.GeofenceStorageSingleton.getInstance()
                    .replaceGeofence(json.encode(thisLocation));
                _endStayPointCandidate = thisLocation;
              }

            });
          }
          else{_endStayPointCandidate = currGeofence; print("[constructor] New location is still in geofence");/* everything is ok */}
        }
      });
    });
  }

  Future<void> _configBckgrnd() async {
    /* print()'s have not been deleted to act as a documentation */

    print("[root_page] Inside configBackgrnd");

    // 1.  Listen to events (See docs for all 12 available events).
    bg.BackgroundGeolocation.onLocation(_onLocation);

    // If Config asks to try to flush trajectories as soon as the app recover internet, register to this callback
    if (CONFIG["connectivityChangeFlush"] == true){
      bg.BackgroundGeolocation.onConnectivityChange(_onConnectivity);
    }

    // Unfoturnately, onGeofence callbacks are never called back ... and the getters is not correctly implementd -> can't use them (cfr. unit tests we did of the api)
    // For this reason, we implement our own geofence framework on top of the backgroundGeolocation api.

    // 2.  Configure the plugin
    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        enableHeadless: CONFIG["enableHeadless"],
        distanceFilter: CONFIG["distanceFilter"],
        foregroundService: CONFIG["foregroundService"],
        stopOnTerminate: CONFIG["stopOnTerminate"], // Controls whether to continue location-tracking after application is shut down
        startOnBoot: CONFIG["startOnBoot"],// will forget its previous state
        // heartbeatInterval: 60, // every 1 min
        // Configure the plugin to emit sound effects and local-notifications during development
        debug: CONFIG["debug"],
        reset: CONFIG["reset"], // Forces BackgroundGeolocation.ready to apply supplied Config with each application launch.
        forceReloadOnGeofence: CONFIG["foreceReloadOnGeofence"],
        forceReloadOnLocationChange : CONFIG["forceReloadOnLocationChange"],
        // Default:
        autoSync : false,
        stopTimeout: CONFIG["stopTimeout"], // https://pub.dartlang.org/documentation/flutter_background_geolocation/latest/flt_background_geolocation/Config/stopTimeout.html
        allowIdenticalLocations : CONFIG["allowIndeticalLocations"],
        notificationChannelName: CONFIG["notificationChannelName"],
        notificationText: CONFIG["notificationText"],
        notificationTitle: CONFIG["notificationTitle"],
        notificationColor: CONFIG["notificationColor"],
        maxRecordsToPersist: CONFIG["maxRecordsToPersist"],
        persistMode: CONFIG["persistMode"],
        disableElasticity: CONFIG["disableElasticity"] // adaptive distance filter for responsiveness of onLocation callbacks based on speed.
      // persistMode: bg.Config.PERSIST_MODE_NONE, // don't use database of background geolocation (because geofence does not work)

    ));

    print("[root_page] BackgrndConfigured");
  }

  /// ---------------
  /// Event handlers
  /// ---------------

  /// The true logic of the background acquisition of the app.
  /// This callback is triggered when the user is detected to be moving with the
  /// accelerometer (and exceeding a radius defined by the config). The callback responsiveness is dependendant of distanceFilter,
  void _onLocation(bg.Location location) {
    /* print()'s have not been deleted to act as a documentation */

    /* 1) ignore sample */
    if (location.sample == true) {
      print("[onLocation] Ignore sample");
      return; // ignore (e.g. sometimes, to get accurate Coords, 3 measures are taken)
    }

    DateTime timestamp = DateTime.now();
    print("[onLocation] RECEIVED LOCATION at $timestamp");

    /* 2) Detect if stayPointCandidate is correct */
    if(_endStayPointCandidate == null){
      // Should no longer happen thanks to initialisation with geofence stored on device
      // or new point if it is outside of the geofence stored on device. See initBackground.
      print("[onLocation] stayPointCandidate is null -> create it");
      _endStayPointCandidate = new Coordinates(location.coords.latitude, location.coords.longitude, timestamp, location.activity.type);
      // _storeNewCoordinatesOnDevice(_endStayPointCandidate); // Don't store this point, it is triggered when the background process is initialized.
    }
    else {
      Coordinates thisLocation = Coordinates( location.coords.latitude, location.coords.longitude, timestamp, location.activity.type);
      Distance distance = new Distance(); // "Vincenty" algorithm, default to round to integer

      double meter = distance(
          new LatLng(location.coords.latitude, location.coords.longitude),
          new LatLng(_endStayPointCandidate.latitude, _endStayPointCandidate.longitude)
      );
      /* Is this location of interest ? */
      if (!_activeTrackingEnabled && _withinGeofence(meter)){
        // skip this point, we don't care, we are not actively tracking and still in the geofence.
        print("[onLocation] not actively tracking, still in geofence -> discard");
      }
      /* Did we loose the signal while we were tracking ? */
      else if (_activeTrackingEnabled && !_withinGeofence(meter) && !_withinTimeFrame(timestamp)){
        // Signal lost: we were actively tracking, but the tracking was lost for a duration superior to the one necessary
        // to determine if we reached a stay point. As this collected point is outside the geofence,
        // we can't trust it or say it is part of this travel (App receives nothing during travel f.e. then turned on 2 hours later in a another city).
        // => Cut trajectory here. This new point will be considered as the start stay point of a new trajectory.
        _readCoordinatesListFromDevice().then((CoordinatesList coordList){
          _flushToServerIfPossibleOtherwiseStoreLocally(thisLocation, coordList).then((void dontCare){
            // Store the center of the geofence on device in case of reboot
            file_manager.GeofenceStorageSingleton.getInstance().replaceGeofence(json.encode(thisLocation));
            print("[onLocation] new geofence stored: set activeTracking to false");
            _activeTrackingEnabled = false;
            _endStayPointCandidate = thisLocation; // center the geofence at last known point
          });
        });
      }
      else {
        /* Store new coordinate in persistent memory */
        _storeNewCoordinatesOnDevice(thisLocation).then((
            CoordinatesList coordList) {

          /* Did we reach the destination of a travel ? */
          if (_activeTrackingEnabled && _isAtDestination(meter, timestamp)) {
            _flushToServerIfPossibleOtherwiseStoreLocally(thisLocation, coordList).then((void dontCare){
              print("[onLocation] surviced to flushToServerIfPossibleOtherwiseStoreLocally");
              // Store the center of the geofence on device in case of reboot
              file_manager.GeofenceStorageSingleton.getInstance().replaceGeofence(json.encode(thisLocation));
              print("[onLocation] new geofence stored: set activeTracking to false");
              _activeTrackingEnabled = false;
              _endStayPointCandidate = thisLocation; // center the geofence at last known point

            });
          }
          /* Are we travelling ("fast") ? */
          else if (_activeTrackingEnabled && _hasExitGeofence(meter)) {
            // middle of travel (in a car, ...)

            print("[onLocation] exit geofence while active tracking: this is the new endStayPoint");
            _endStayPointCandidate = thisLocation;
          }
          /* Did we start a travel ? */
          else if (!_activeTrackingEnabled && _hasExitGeofence(meter)) {

            // Start active tracking
            _activeTrackingEnabled = true;
            _endStayPointCandidate = thisLocation; // quid je vais juste à la frontière de la geofence + epsilon et j'y reste 20 min ? Discard sur serveur.
            print("[onLocation] exited geofence area while not active tracking -> start active tracking");
          }
          /* We detect we are travelling but this point is close enough geographically to the previous one to be a hint that we may arrive at destination shortly.*/
          else {
            // Active tracking enabled, whithin geofence but for not enought time to be considered as a stay point (aka the destination in this case).
            // Nothing special to do apart noticing it for documentation.
            print("[onLocation] active tracking ($_activeTrackingEnabled) within geofence area, but for not enought time for stay point");
          }
        }); // tried storing coordinate list
      }
    }
  }

  /// Callback that is triggered when the internet connection is recovered (4G/Wifi)
  void _onConnectivity(bg.ConnectivityChangeEvent e) {

    try{
      if (e.connected){
        // Check if we can use the 4G
        _cond2Send2ServerRespected().then((bool onValue) {
          if (onValue == true) {

            _readTrajectoriesFromDevice().then((PoolTrajectories pool){

              if (pool != null  && pool.trajectories != null && !pool.isEmpty()){

                _flushTrajectories2Server(pool).then((bool success) {
                  print("[onConnectivity] Now flushing");
                  if (success) {
                    print(
                        "[onConnectivity] flush success -> empty trajectories on device");
                    file_manager.PoolTrajectoriesStorageSingleton.getInstance().clean();
                  }
                  else {
                    print("[onConnectivity] Could not send trajectories to server: $e");
                  }
                });
              }
              else{
                print("[onConnectivity] Nothing to send");
              }
            }).catchError((var e){
              // If trajectory pool is empty, the exception is triggered
              print("[onConnectivity] Nothing to send");
            }); // read coord on device
          }
        }); // cond2Send2ServerRespected
      } // Connected
    }
    catch (e){
      // Can fall here if no trajectory pool has ever been stored on the device yet.
      print("[onConnectivity] Nothing to send");
    }
  }

  void stopBackgroundLocation(){
    bg.BackgroundGeolocation.stop().then((bg.State state) {
      print('[stop] success: $state');
      // Reset odometer.
      bg.BackgroundGeolocation.setOdometer(0.0);
    });
  }



  /// --------------------------------------------------------------------------
  ///                       Logic for data acquisition methods
  ///                       **********************************
  /// --------------------------------------------------------------------------

  bool _isAtDestination(double dist, DateTime newLocTime){
    return dist < CONFIG["stayPointGeoRadius"] && newLocTime.difference(_endStayPointCandidate.dateTime).inMinutes > CONFIG["durationStayPoint"];
  }

  bool _withinTimeFrame(DateTime newLocTime){
    return newLocTime.difference(_endStayPointCandidate.dateTime).inMinutes < CONFIG["durationStayPoint"];
  }

  bool _hasExitGeofence(double dist){
    return dist > CONFIG["stayPointGeoRadius"];
  }

  bool _withinGeofence(double dist){
    return dist < CONFIG["stayPointGeoRadius"];
  }

  Future<bool> _cond2Send2ServerRespected() async {
    String mean = await getInternetCoMean();
    String cellular = "";
    bool cellularAllowedByUser;
    try {
      cellularAllowedByUser =
      await shared_pref.Settings.getSwitchValue("MobileDataON", false);
      if (cellularAllowedByUser){
        cellular = "cellular";
      }
    }
    catch(e){
      // by default, false
      cellularAllowedByUser = false;
    }

    final String wifi = "wifi";
    return (mean == wifi) || (mean == cellular);
  }

  Future<void> _flushToServerIfPossibleOtherwiseStoreLocally(Coordinates thisLocation, CoordinatesList coordList) async{
    print("[onLocation] detected at destination");

    Coordinates startStayPoint = coordList.content[0];
    Trajectory traj = Trajectory.build(
        startStayPoint, coordList, _endStayPointCandidate);

    _storeNewTrajectoryOnDevice(traj).then((PoolTrajectories pool) {
      print("[onLocation] Trajectory added to pool, ready to sync with server");

      _cond2Send2ServerRespected().then((bool satisfied) {
        if (satisfied) {
          print("[onLocation] condition to send to server respected -> flush");
          _flushTrajectories2Server(pool).then(( bool success){
            if (success){
              print("[onLocation]flush success -> empty trajectories on device");
              file_manager.PoolTrajectoriesStorageSingleton.getInstance().clean();
            }
            else{
              print("[onLocation] Could not send trajectories to server");
            }
          });
        }
        else {print("[onLocation] condition to send to server not respected");/* trajectories will be flushed when internet available*/ }
      });
      // In any case, we empty the coordinate list that will be filled for next trajectory
      file_manager.CoordinatesStorageSingleton.getInstance().clean();

    });
  }


  Future<bool> _flushTrajectories2Server(PoolTrajectories pool) async {

    String batchTrajectories = json.encode(pool);
    print("[onLocation] batchTrajectories = $batchTrajectories");

    ServerReply reply = await NetworkUtilsSingleton.getInstance().sendTrajectories(batchTrajectories);
    if (reply.isSuccess()){
      print("[onLocation] Succeeded to send trajectories to server");
      file_manager.PoolTrajectoriesStorageSingleton.getInstance().clean();
      return true;
    }
    else{
      print("[onLocation] Tried to send trajectories to server but failed on: \n ${reply.content}\n\n");
      return false; // Can't reach server, never mind, will try later.
    }
  }


  /// --------------------------------------------------------------------------
  ///                               Storage methods
  ///                               ***************
  /// --------------------------------------------------------------------------
  Future<CoordinatesList> _storeNewCoordinatesOnDevice(Coordinates coord) async {
    // TODO: return the coordList
    CoordinatesList coordList;

    try {
      coordList = await _readCoordinatesListFromDevice();
    } on FormatException {
      // add catch(e) after Format exception if want instance of error
      print("That string didn't look like Json.");
    } on NoSuchMethodError {
      print('That string is null!');
    } catch (e) {
      print("File does not yet exist");
    }


    if (coordList != null && coordList.content != null)
      coordList.content.add(coord);
    else {
      print("coordList is null");
      List<Coordinates> itinary = new List();
      itinary.add(coord);
      coordList =
      new CoordinatesList(new DateTime.now(), null, itinary);
      print("Now it is not: first initialization");
    }

    file_manager.BaseStorageCoordinatesUtils storage = file_manager.CoordinatesStorageSingleton.getInstance();
    await storage.storeCoordinatesList(json.encode(coordList.toJson()));
    print("[storeNewCoordinates] coordList is null ? ${coordList == null}");
    return coordList;
  }

  Future<CoordinatesList> _readCoordinatesListFromDevice() async {
    // write the variable as a string to the file
    file_manager.BaseStorageCoordinatesUtils storage = file_manager.CoordinatesStorageSingleton.getInstance();
    String jsonString = await storage.readCoordinatesList();

    if (jsonString == null){
      print("We read: null coordList in memory");
      return null;
    }
    else if (jsonString == "") {
      print("We read: a coordList that is empty in memory");
      return null;
    }
    else{
      print("We read: $jsonString in memory");
      Map coordListMap = json.decode(jsonString);
      return CoordinatesList.fromJson(coordListMap);
    }
  }

  Future<PoolTrajectories> _readTrajectoriesFromDevice() async {
    file_manager.BaseStorageTrajectoryUtils storage = file_manager.PoolTrajectoriesStorageSingleton.getInstance();
    String jsonString = await storage.readPoolTrajectories();
    print("We read $jsonString in memory");
    Map poolTrajectoriesMap = json.decode(jsonString);
    return PoolTrajectories.fromJson(poolTrajectoriesMap);
  }


  Future<PoolTrajectories> _storeNewTrajectoryOnDevice(Trajectory traj) async {
    PoolTrajectories pool; // Batch of trajectories to send to server

    try {
      pool = await _readTrajectoriesFromDevice();
    } on FormatException {
      // add catch(e) after Format exception if want instance of error
      print("That string didn't look like Json.");
    } on NoSuchMethodError {
      print('That string was null!');
    } catch (e) {
      print("File does not yet exist");
    }


    if (pool != null && pool.trajectories != null)
      pool.add(traj);
    else {
      print("Trajectories is null");
      pool = PoolTrajectories();
      pool.add(traj);
      print("Now it is not: first initialization");
    }


    try {
      file_manager.BaseStorageTrajectoryUtils storage = file_manager.PoolTrajectoriesStorageSingleton.getInstance();
      await storage.storePoolTrajectories(json.encode(pool));
      return pool;
    }
    catch (e){
      print("[storeNewTrajectoryOnDevice] Error : $e");
      return pool;
    }
  }



  /// --------------------------------------------------------------------------
  ///                        UI (root to proper widget)
  ///                        **************************
  /// --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context){
    switch(authStatus){
      case AuthStatus.notLoggedIn:
        // Go to login then
        return new LoginPage(
          onSignedIn: _signedIn,
        );
      case AuthStatus.loggedIn:
        // Go to home then
        return new HomePage(
          onSignedOut: _signedOut,
        );
    }
    return new LoginPage();
  }
}