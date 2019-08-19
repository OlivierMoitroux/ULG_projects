import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:gps_tracer/utils/colors.dart';
import 'package:gps_tracer/utils/colors.dart' as myColors;

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

/// To display pretty json formatting
JsonEncoder encoder = new JsonEncoder.withIndent("     ");


Timer timer;

/// Part of the historical page to debug the background location. Useful to monitor its state and current tracking.<br>
/// Functionalities include
///   * Allows the user to see if the background process is running. The button can turn it on/off
///   * Get the current location (add it to coordinates list like if it was fetched automatically)
///   * Monitor the activity of the user detected. Can force it to false or true. Affect the acquisition process.
///   When still, the user has to move 30m by default to enter the new moving state. Otherwise, no data is acquired in background to save battery.
class BackgroundStatePage extends StatefulWidget {

  @override
  _BackgroundStatePageState createState() => new _BackgroundStatePageState();
}

class _BackgroundStatePageState extends State<BackgroundStatePage>{

  bool _isMoving = false;
  bool _enabled = false;
  String _content = "Empty";
  bool _activeTrackingEnabled; // Historical, before, was monitoring this variable as well (can still find it in root page).

  _BackgroundStatePageState(){
    print("inside constructor");
    _activeTrackingEnabled = true;
    _isMoving = false;
    _enabled = false;
    _content = "Not yet fetched";

  }

  @override
  void initState() {
    /// As this page does not control the background process logic (cfr. root_page) anymore,
    /// it can't display the state of the background process upon receiving a fresh new callback.
    /// For this reason, we use a timer to periodically look for update. The timer is shut down when exiting this page.
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => getState());
    super.initState();
    getState();

  }

  Future<void> getState() async{

    if (this.mounted){
      bg.State state = await bg.BackgroundGeolocation.state;

      // Content to display
      String contentTmp = "";

      /// Get last locations fetched in background from sql lite database
      List<dynamic> locList = await bg.BackgroundGeolocation.locations;
      if (locList.length > 0){
        contentTmp = encoder.convert(locList[locList.length-1]);
      }
      else{
        contentTmp = "No recent coordinates to display";
      }

      setState(() {
        _enabled = state.enabled;
        _isMoving = state.isMoving;
        _content = contentTmp;
      });
    }
    else{
      // Stop timer, the widget is not active anymore
      timer.cancel();
    }

  }

  /// ----------------
  /// Click callbacks
  /// ----------------
  ///

  /// Manually toggle the tracking state:  moving vs stationary
  void _onClickChangePace() {
    setState(() {
      _isMoving = !_isMoving;
    });
    print("[onClickChangePace] -> $_isMoving");

    bg.BackgroundGeolocation.changePace(_isMoving).then((bool isMoving) {
      print('[changePace] success $isMoving');
    }).catchError((e) {
      print('[changePace] ERROR: ' + e.code.toString());
    });
  }

  void _onClickEnable(enabled) {

    if (enabled) {
      print("Should start the service");
      // Start the plugin
      bg.BackgroundGeolocation.start().then((bg.State state) {
        print('[start] success $state');
        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        print('[stop] success: $state');
        // Reset odometer.
        bg.BackgroundGeolocation.setOdometer(0.0);

        setState(() {
          _enabled = state.enabled;
          _isMoving = state.isMoving;
        });
      });
    }
  }

  /// Manually fetch the current position.
  void _onClickGetCurrPos() {
    bg.BackgroundGeolocation.getCurrentPosition(
        persist: false,     // <-- do not persist this location
        desiredAccuracy: 0, // <-- desire best possible accuracy
        timeout: 30000,     // <-- wait 30s before giving up.
        samples: 3          // <-- sample 3 location before selecting best.
    ).then((bg.Location location) {
      print('[getCurrentPosition] - $location');
    }).catchError((error) {
      print('[getCurrentPosition] ERROR: $error');
    });
  }

  /// --------------------------------------------------------------------------
  ///                               Widget building
  ///                               ***************
  /// --------------------------------------------------------------------------
  ///
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: myColors.covoitULiegeColor,
          title: new Center(
        child:new Text('Background state')),
        ),
        body:
        new ListView(
          // Destroy the axis alignement of the column though
            padding: EdgeInsets.only(top: 40.0, left: 24.0, right: 24.0),
            children: <Widget>[
              new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    /// GUI for background stuff

                    new Text("Background DEBUG",
                        style: TextStyle(fontSize: 32.0, color: Colors.black54),
                        textAlign: TextAlign.center),

              new Container(height: 30.0,),
              /// Buttons
              new Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[

                        new FloatingActionButton(
                            backgroundColor: (_isMoving) ? Colors.red :covoitULiegeColor,
                            // On tap, gets the coordinates of the current position
                            onPressed: _onClickChangePace,
                            tooltip: 'Simulate moving 2',
                            child: (_isMoving)? new Icon(Icons.stop) : new Icon(Icons.directions_run), heroTag: '1',
                        ),
                        new FloatingActionButton(
                            backgroundColor: covoitULiegeColor,
                            // On tap, gets the coordinates of the current position
                            onPressed: _onClickGetCurrPos, //_getLocation,
                            tooltip: 'Get location with fpl 2',
                            child: new Icon(Icons.gps_fixed), heroTag: '2',),
                        new FloatingActionButton(
                            backgroundColor: (_enabled) ? Colors.red : covoitULiegeColor,
                            // On tap, gets the coordinates of the current position
                            onPressed: (){_enabled=!_enabled;_onClickEnable(_enabled);}, //_getLocation,
                            tooltip: 'Get location with fpl 2',
                            child: new Icon((_enabled) ? Icons.stop : Icons.play_arrow), heroTag: '3',)


                        ]
                  )
              ),

                    new Container(height: 30,),
                    new Text('$_content'),

                  ]
              )
            ]
        )
    );
  }


}