import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:gps_tracer/utils/colors.dart';
import 'package:gps_tracer/utils/alert_box.dart';

/// Debug page to be sure every permissions are set
class RightsPage extends StatefulWidget {

  @override
  _RightsPageState createState() => new _RightsPageState();
}

class _RightsPageState extends State<RightsPage>{


  String _platformVersion = 'Unknown';
  Permission permission;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await SimplePermissions.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Permissions manager'),
          backgroundColor: covoitULiegeColor,
        ),
        body: new Center(
          child: new Column(children: <Widget>[
            new SizedBox(height: 18.0),
            new Text('Running on: $_platformVersion\n'),
            new DropdownButton(
                items: _getDropDownItems(),
                value: permission,
                onChanged: onDropDownChanged),
            new RaisedButton(
                onPressed: checkPermission,
                child: new Text("Check permission", style: TextStyle(color: Colors.white))),
            new RaisedButton(
                onPressed: requestPermission,
                child: new Text("Request permission", style: TextStyle(color: Colors.white))),
            new RaisedButton(
                onPressed: getPermissionStatus,
                child: new Text("Get permission status", style: TextStyle(color: Colors.white))),
            new RaisedButton(
                onPressed: SimplePermissions.openSettings,
                child: new Text("Open settings", style: TextStyle(color: Colors.white)))
          ]),
        ),
    );
  }

  onDropDownChanged(Permission permission) {
    setState(() => this.permission = permission);
    print(permission);
  }

  requestPermission() async {
    final res = await SimplePermissions.requestPermission(permission);
    showDialogBox(context, "Permission request result:", res.toString());
    print("permission request result is " + res.toString());
  }

  checkPermission() async {
    bool res = await SimplePermissions.checkPermission(permission);
    showDialogBox(context, "Check permission:", res.toString());
    print("permission is " + res.toString());

  }

  getPermissionStatus() async {
    final res = await SimplePermissions.getPermissionStatus(permission);
    showDialogBox(context, "Permission status:", res.toString());
    print("permission status is " + res.toString());
  }

  List<DropdownMenuItem<Permission>> _getDropDownItems() {
    List<DropdownMenuItem<Permission>> items = new List();
    Permission.values.forEach((permission) {
      var item = new DropdownMenuItem(
          child: new Text(getPermissionString(permission)), value: permission);
      items.add(item);
    });
    return items;
  }
}