import 'dart:async';
import 'package:gps_tracer/models/coordinates.dart';
import 'package:flutter/material.dart';
import 'package:gps_tracer/utils/colors.dart' as myColors;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'dart:convert';
import 'package:gps_tracer/store/file_manager.dart';
import 'package:geocoder/geocoder.dart' as geocoder;

/// for pretty display of json
JsonEncoder encoder = new JsonEncoder.withIndent("     ");

/// A page to monitor the current configuration of the background location process + curr geofence stored on device memory
class BackgroundConfigPage extends StatefulWidget {

  @override
  _BackgroundConfigPageState createState() => new _BackgroundConfigPageState();
}

class _BackgroundConfigPageState extends State<BackgroundConfigPage>{
 String _config = "";
 String _geofence ="";
 String _content = "";
 String _addr = "";


 Future<void> _getConfig() async {
   print("button clicked");
   bg.State config = await bg.BackgroundGeolocation.state;

   String currGeofence = await GeofenceStorageSingleton.getInstance().readCurrGeofence();

   if (currGeofence == null || currGeofence ==""){
     currGeofence = "{No geofence in memory}";
   }
   Map coordListMap = json.decode(currGeofence);
   Coordinates coord = Coordinates.fromJson(coordListMap);
   final geocoder.Coordinates coord2 = geocoder.Coordinates(coord.latitude, coord.longitude);
   var addrList = await geocoder.Geocoder.local.findAddressesFromCoordinates(coord2);

   setState(() {
     _config = "BACKGROUND CONFIG:\n====================\n"+encoder.convert(config.toMap())+"\n";
     _geofence = "\nCURRENT GEOFENCE\n==================\n"+currGeofence;
     _addr = "\n\nAddress is " + addrList.first.addressLine;
     _content = _config+_geofence+_addr;
   });

 }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: myColors.covoitULiegeColor,
        title: new Text( 'Data acquisition configuration'),
      ),
      body:

new ListView(
    // Destroy the axis alignement of the column though
    padding: EdgeInsets.only(top: 40.0, left: 24.0, right: 24.0),
    children: <Widget>[
            RaisedButton(
              child: Text('Get current config', style: TextStyle(color: Colors.white)),
              onPressed: _getConfig,
            ),
            new Container(height: 30,),
            new Text(_content, style: TextStyle(color: Colors.black.withOpacity(0.6))),
            new Container(height: 30,),
          ],
        ),
      );
  }

}
