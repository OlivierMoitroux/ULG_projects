import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:gps_tracer/network/network_utils.dart';
import 'package:gps_tracer/utils/colors.dart';
import 'package:gps_tracer/store/shared_pref.dart' as shared_pref;
import 'package:gps_tracer/store/file_manager.dart' as file_manager;
import 'package:gps_tracer/utils/alert_box.dart' as alert_box;
import 'package:gps_tracer/store/secured_storage.dart';
import 'package:gps_tracer/models/habits.dart';

import 'package:gps_tracer/models/coordinates.dart';
import 'package:gps_tracer/models/login.dart';
import 'package:gps_tracer/models/register_data.dart';
import 'package:gps_tracer/models/session.dart';
import 'package:gps_tracer/models/trajectory.dart';
import 'dart:convert';


/// A DevButton is a setting button with a leading icon and a trailing cheveron
/// that redirects the user onto a new page via the function [onTap].
class DevButton extends StatelessWidget {
  final String _title;
  final GestureTapCallback _onTap;
  final Icon _icon;
  final String _subtitle;

  DevButton(this._title, this._onTap, this._subtitle, this._icon);

  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: new BoxDecoration(color: Colors.white),
        child: new Column(
          children: <Widget>[
            new ListTile(
              leading: _icon, // Icon(Icons.info_outline)
              trailing: Icon(Icons.chevron_right),
              title: Text('$_title'),
              subtitle: _subtitle != null
                  ? new Text(_subtitle)
                  : null, // _parameterValue == 0 ? const Text("This is a subtitle") : null,
              onTap: _onTap,
            ),
            new Divider(
              height: 0.0,
            ),
          ],
        ));
  }
}

/// Simple button that perform a one shot action via the function [onTap]
class NormalButton extends StatelessWidget {
  final String _title;
  final GestureTapCallback _onTap;
  final Icon _icon;
  final String _subtitle;

  NormalButton(this._title, this._onTap, this._subtitle, this._icon);

  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: new BoxDecoration(color: Colors.white),
        child: new Column(
          children: <Widget>[
            new ListTile(
              leading: _icon, // Icon(Icons.info_outline)
              title: Text('$_title'),
              subtitle: _subtitle != null
                  ? new Text(_subtitle)
                  : null, // _parameterValue == 0 ? const Text("This is a subtitle") : null,
              onTap: _onTap,
            ),
            new Divider(
              height: 0.0,
            ),
          ],
        ));
  }
}

/// Custom switch button (early dev.)
class MySwitchListTile extends StatefulWidget {
  final String _title;
  final Icon _icon;
  final bool _value;
  final String _subtitle;
  final String _spID;

  MySwitchListTile(this._title, this._subtitle, this._icon, this._value, this._spID);

  @override
  _MySwitchListTileState createState() => new _MySwitchListTileState();
}

class _MySwitchListTileState extends State<MySwitchListTile> {
  bool _v = false;

  void _init() async {
    _v = await shared_pref.Settings.getSwitchValue(widget._spID, widget._value);

    setState(() {});
  }

  Future<dynamic> _initDebug() async{
    _v = await shared_pref.Settings.getSwitchValue(widget._spID, widget._value);
    return _v;
  }


  @override
  void initState() {
    super.initState();
    _initDebug().then((_v) {
      print("Widget '${widget._title}' is initialized to:");
      print(_v);
      setState(() {});
    });
  }

  void _onChanged(value) async {
    print("onChanged:$value, old _v=$_v");
    await shared_pref.Settings.setSwitchValue(widget._spID, value);
    _v = await shared_pref.Settings.getSwitchValue(widget._spID, widget._value);
    print("new _v=$_v");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: new BoxDecoration(color: Colors.white),
        child: new Column(
          children: <Widget>[
            new SwitchListTile(
                secondary: widget._icon,
                // trailing: Icon(Icons.chevron_right),
                title: Text(widget._title),
                activeColor: covoitULiegeColor,
                subtitle: widget._subtitle != null
                    ? new Text(widget._subtitle)
                    : null,
                value: _v,
                onChanged: (value) => _onChanged(value)),
            new Divider(
              height: 0.0,
            ),
          ],
        ));
  }
}

/// Simple header to classify content in the settings of the app.
/// ```topBorder``` is a boolean. If true, the button features a line separation at
/// its top.
class Header extends StatelessWidget {
  final String _title;
  final bool _topBorder;
  Header(this._title, this._topBorder);

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new ListTile(
          title: new Text(
            _title,
            style: new TextStyle(color: covoitULiegeColor),
          ),
        ),
        decoration: new BoxDecoration(
          border: _topBorder == true
              ? new Border(
              top: new BorderSide(color: Colors.black26, width: 0.5))
              : null,
          color: Colors.white,
        ));
  }
}

/// A page menu with all the dev. tools for advanced debugging and monitoring
class SettingsDebugPage extends StatefulWidget {
  final VoidCallback onSignOutClick;
  SettingsDebugPage({this.onSignOutClick});

  @override
  State createState() => new SettingsDebugPageState();

}

class SettingsDebugPageState extends State<SettingsDebugPage> {
  static var values = {"Localization": true, "Mobile data": false};

  Future<bool> _cleanDataOnDevice() async {
    print("Deleting files");
    bool coordDestroyed; bool trajDestroyed;
    coordDestroyed = await file_manager.CoordinatesStorageSingleton.getInstance().clean();
    trajDestroyed = await file_manager.PoolTrajectoriesStorageSingleton.getInstance().clean();
    return coordDestroyed && trajDestroyed;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            backgroundColor: covoitULiegeColor,
            title: new Center(
                child: new Text("Developper tools",
                    style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)))),
        body:
    new ListView(
        padding: new EdgeInsets.symmetric(vertical: 5.0),
        children: <Widget>[

          new Header("DEBUG", false),
          new DevButton("Background geolocation state", () {
            Navigator.pushNamed(context, '/background_state');
          }, "", new Icon(Icons.gps_off)),

          new DevButton("Background geolocation config", () {
            Navigator.pushNamed(context, '/background_config');
          }, "", new Icon(Icons.content_paste)),

          new DevButton("View current coordinate list", () {
            Navigator.pushNamed(context, '/coordinates_list_page');
          }, "", new Icon(Icons.list)),


          new DevButton("View current trajectory pool", () {
            Navigator.pushNamed(context, '/trajectory_list_page');
          }, "", new Icon(Icons.directions_transit)),


          new DevButton("Manage permissions", () {
            Navigator.pushNamed(context, '/rights_manager');
          }, "", new Icon(Icons.perm_device_information)),
          new NormalButton(
              "Test session alive",
                  (){SecuredStorageSingleton.getSession().then((String sess){
                alert_box.showDialogBox(context, "Crypted session stored:", sess);
              });},
              "Display your username and password",
              new Icon(Icons.no_encryption)
          ),

          new NormalButton("Check internet connection", () {
            getInternetCoMean().then((mean){
              alert_box.showDialogBox(context, "Your internet connection is:", mean);
            });
            //print(getInternetCoMean());
          }, "", new Icon(Icons.perm_scan_wifi)),

          new NormalButton("See JSON format used on app", () {
            _printJSONmodelsInConsole();
          }, "Result displayed in console only", new Icon(Icons.insert_drive_file)),

          new NormalButton("Send fictiv trajectories", () {
            _sendFictivTrajectories();
          }, "Result displayed in console only", new Icon(Icons.send)),
          new NormalButton("Get Config", () {
            _getConfig();
          }, "Result displayed in console only", new Icon(Icons.cloud_download)),


        ]));
  }
}
Future<void> _getConfig() async {
  ServerReply reply = await NetworkUtilsSingleton.getInstance().getInitConfig();
  if (reply.isSuccess()){
    Map configMap = json.decode(reply.content);
    print("Success");

  }else{
    print("Could not get config ${reply.content}");
  }

}
Future<void> _sendFictivTrajectories() async {
  Coordinates coord = new Coordinates(3.0, -4.0, DateTime.now(), "on_foot");
  Coordinates coord2 = new Coordinates(-6.0, 5.0, DateTime.now(), "unknown");
  Coordinates coord3 = new Coordinates(-8.0, 5.0, DateTime.now(), "unknown");
  List<Coordinates> coordListTmp = new List();
  coordListTmp.add(coord);
  coordListTmp.add(coord2);
  CoordinatesList coordList = new CoordinatesList(DateTime.now(), DateTime.now(), coordListTmp);
  Trajectory traj = Trajectory.build(coord, coordList, coord2);
  Trajectory traj2 = Trajectory.build(coord2, coordList, coord3);

  PoolTrajectories poolTraj = new PoolTrajectories();
  poolTraj.add(traj);
  poolTraj.add(traj2);

  ServerReply reply = await NetworkUtilsSingleton.getInstance().sendTrajectories(json.encode(poolTraj));
  print("[SUCCESS] ${reply.isSuccess()}");
  print("[CONTENT] ${reply.content}");
}


/// IF you want to see how the JSON's look like, consult the output of this function (use the UI ...)
void _printJSONmodelsInConsole(){
  Coordinates coord = new Coordinates(3.0, -4.0, DateTime.now(), "on_foot");
  Coordinates coord2 = new Coordinates(-6.0, 5.0, DateTime.now(), "unknown");
  Coordinates coord3 = new Coordinates(-8.0, 5.0, DateTime.now(), "unknown");
  List<Coordinates> coordListTmp = new List();
  List<Coordinates> coordListTmp2 = new List();
  coordListTmp.add(coord);
  coordListTmp.add(coord2);
  coordListTmp2.add(coord3);
  CoordinatesList coordList = new CoordinatesList(DateTime.now(), DateTime.now(), coordListTmp);
  CoordinatesList coordList2 = new CoordinatesList(DateTime.now(), DateTime.now(), coordListTmp2);
  LoginData login = new LoginData();
  login.username = "Jean-Paul 2";
  login.password = "Notre_Dame_de_Paris";
  RegisterData regData = new RegisterData(username:"Jean-Paul 2", password:"Notre_Dame_de_Paris", passwordConf:"Notre_Dame_de_Paris", email:"jp2@vatican.it", homeAddress:"Hotel", homeZip:"4450", homeCountry:"Vatican", workAddress:"Eglise St-Machin", workZip:"5567", workCountry:"Italy", work:"Student");


  print("Profession can be ['Student', 'Teacher', 'Administrative staff', 'Other']");
  Session sess = new Session("fdhifh5578687GHugyugezuf767", DateTime.now());

  Trajectory traj = Trajectory.build(coord, coordList, coord2);
  Trajectory traj2 = Trajectory.build(coord2, coordList2, coord3);

  PoolTrajectories poolTraj = new PoolTrajectories();
  poolTraj.add(traj);
  poolTraj.add(traj2);

  HabitsData hd = HabitsData(startCity:"Liège", startStreet:"Rue St-Gilles 43", startTime:"fjfeozij", endCity:"Sart-Tilman",
      endStreet:"Allée de la découverte 10", endTime:"fdsfs", weekDay:"lndi", date:"ma_date", timing:"fefez", locomotion:"on_foot", scoring:3.5);

  JsonEncoder encoder = new JsonEncoder.withIndent("     ");
  String coordStr = encoder.convert(coord);
  String coordListStr = encoder.convert(coordList);
  String loginStr = encoder.convert(login);
  String regDataStr = encoder.convert(regData);
  String sessStr = encoder.convert(sess);
  String trajStr = encoder.convert(traj);
  String poolTrajStr = encoder.convert(poolTraj);
  String habitsStr = encoder.convert(hd);

  String tmp = json.encode(poolTraj);

  print("Coordinates:\n$coordStr");
  print("----------------------------------");
  print("CoordinatesList:\n$coordListStr");
  print("----------------------------------");
  print("LoginData:\n$loginStr");
  print("----------------------------------");
  print("RegisterData:\n$regDataStr");
  print("----------------------------------");
  print("Session:\n$sessStr");
  print("----------------------------------");
  print("Trajectory:\n$trajStr");
  print("----------------------------------");
  print("PoolTrajectories:\n$poolTrajStr");
  print("----------------------------------");
  print("habits:\n$habitsStr");
  print("----------------------------------");

}