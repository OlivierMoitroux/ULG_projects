import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:gps_tracer/network/network_utils.dart';
import 'package:gps_tracer/utils/colors.dart';
import 'package:gps_tracer/store/shared_pref.dart' as shared_pref;
import 'package:gps_tracer/store/file_manager.dart' as file_manager;
import 'package:gps_tracer/utils/alert_box.dart' as alert_box;
import 'package:gps_tracer/network/privacy_policy.dart' as pp;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:gps_tracer/pages/settings/manage_account_page.dart';

/// A DevButton is a setting button with a leading icon and a trailing cheveron
/// that redirects the user onto a new page via the function ```onTap```.
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
    // Or use then() instead
    // _init();
    _initDebug().then((_v) {
      setState(() {});
    });
  }

  void _onChanged(value) async {
    //alert_box.showDialogBox(context, "", "");
    print("onChanged:$value, old _v=$_v");
    await shared_pref.Settings.setSwitchValue(widget._spID, value);
    _v = await shared_pref.Settings.getSwitchValue(widget._spID, widget._value);

    if (widget._spID == "LocationON"){
      if (_v == true)
        bg.BackgroundGeolocation.start();
      else
        bg.BackgroundGeolocation.stop();
    }

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


class SettingsPage extends StatefulWidget {


  final VoidCallback onSignOutClick;
  SettingsPage({this.onSignOutClick});


  @override
  State createState() => new SettingsPageState();

}

class SettingsPageState extends State<SettingsPage> {
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
    return new ListView(
        padding: new EdgeInsets.symmetric(vertical: 5.0),
        children: <Widget>[
          new Header("General information", false),
          new DevButton("About", () {
            Navigator.pushNamed(context, '/about');
          }, "Developpers, goals, ...", new Icon(Icons.info_outline)),
          new NormalButton("Privacy policy", (){pp.launchURLPrivPolicy(context);}, null, new Icon(Icons.remove_red_eye)),
          new Header("Network and localization", true),
          new MySwitchListTile(
              "Allow use of mobile data in background",
              null,
              new Icon(Icons.swap_vert),
              false,
              "MobileDataON"
          ),
          new MySwitchListTile(
              "Allow location",
              "Otherwise, turn off location until next login",
              new Icon(Icons.gps_fixed),
              true,
              "LocationON"
        ),
          new Header("Account", true),
          new NormalButton("Log out", () {
            // Use a callback in a stateful widget to retrieve user choice
            void _onAccept(){
              print("logging out and stopping background aquisition");
              bg.BackgroundGeolocation.stop();
              // Important, otherwise, if login again, there will be two listeners !
              bg.BackgroundGeolocation.removeListeners();
              widget.onSignOutClick();
            }
            alert_box.ConfirmAlertBox(context, "Logging out.", "Are you sure ?", _onAccept);
          }, null, new Icon(Icons.keyboard_tab)),
          new DevButton("Manage my account", () {
            //Navigator.pushNamed(context, '/lorem');
            //Navigator.pushNamed(context, '/account_management_page');
            Navigator.push(context, new MaterialPageRoute(builder: (context) => new AccountManagementPage(widget.onSignOutClick)));
            //alert_box.showDialogBox(context, "Oups ...", "This feature is not yet implemented");
          }, null, new Icon(Icons.account_circle)),

          new Header("DEBUG", true),
          new DevButton("Developper tools", () {
            Navigator.pushNamed(context, '/debug_settings_page');
          }, "", new Icon(Icons.bug_report)),

          new NormalButton(
              "Report a bug",
              (){NetworkUtilsSingleton.getInstance().sendLogs("olivier.moitroux@gmail.com");},
              "Please add your message on top",
              new Icon(Icons.bug_report)
          ),
          // TODO: change my address to one in CONFIG map ?
        ]);
  }
}


/*
CHANGE ANNIMATION |e| screens:
--------------------------------

import 'slide_transition.dart';

Navigator.push(
  context,
  SlideRightRoute(widget: DetailScreen()),
);

OU

Navigator.of(context).push(new AboutScreenRoute());

OU

 Navigator.of(context).push(new SlideRightRoute(widget: AboutScreen()));
 */
