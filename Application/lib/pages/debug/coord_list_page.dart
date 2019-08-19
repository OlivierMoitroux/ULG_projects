import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gps_tracer/store/file_manager.dart';
import 'package:gps_tracer/models/coordinates.dart';
import 'package:gps_tracer/utils/colors.dart';
import 'package:geocoder/geocoder.dart' as geocoder;

class CoordinatesTile extends StatefulWidget{
  final Coordinates _coordinates;
  CoordinatesTile(this._coordinates);
  @override
  State createState() => new CoordinatesTileState(_coordinates);
}

/// The Coordinates class represents an element of the displayed coordinates list
class CoordinatesTileState extends State<CoordinatesTile> {
  Coordinates _coordinates;
  String address;

  CoordinatesTileState(this._coordinates){
    /// Geocoder can fail, known issue but not yet fixed by google.
    try {
      final geocoder.Coordinates coord = geocoder.Coordinates(
          _coordinates.latitude, _coordinates.longitude);
      geocoder.Address first;
      geocoder.Geocoder.local.findAddressesFromCoordinates(coord).then((
          var addresses) {
        var first = addresses.first;
        print("${first.featureName} : ${first.addressLine}");
        setState(() {
          address = first.addressLine;
        });
      }).catchError((e){print("[error]: Geocoder did not work, $e");});
    }
    catch (e){
      // Can't do anything about it
      print("[error]: Geocoder did not work: \n\n $e");
    }
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int _day = _coordinates.dateTime.day;
    final int _month = _coordinates.dateTime.month;
    final int _year = _coordinates.dateTime.year;
    final int _hour = _coordinates.dateTime.hour;
    final int _minute = _coordinates.dateTime.minute;
    final int _second = _coordinates.dateTime.second;

    return new Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 1.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        alignment: Alignment.center,
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text("Latitude: ${_coordinates.latitude}"),
              new Text("Longitude: ${_coordinates.longitude}"),
              new Text("Date: $_day/$_month/$_year"),
              new Text("Hour: $_hour:$_minute:$_second"),
              address==null?new Text("Addr: ?"):new Text("Addr: $address")
            ]));
  }
}

/// A widget page to monitor the coordinates stored on the device that are waiting to be processed and transformed into a trajectory.
/// Once the trajectory is built from this data, the coordinate list is emptied.
class CoordinatesListPage extends StatefulWidget {
  // Storage is used to retrieve the coordinates list that is stored on the
  // device memory
  // Improvement: use the singleton instead. This is for historical reason. As it is just a debug page, not crucial.
  final JSONCoordinatesStorage storage = new JSONCoordinatesStorage();
  @override
  State createState() => new CoordinatesListPageState();
}

class CoordinatesListPageState extends State<CoordinatesListPage> {
  // List of CoordinatesTile widget to display the stored Coordinates and
  // associated data on the device memory
  List<CoordinatesTile> coordWidgetList = new List();

  @override
  void initState() {
    super.initState();
    try {
      widget.storage.readCoordinatesList().then((String jsonString) {
        setState(() {
          // Required to avoid bug in the display
          coordWidgetList.clear();
          if (jsonString != null) {
            print("CoordinatesList = $jsonString");

            if (jsonString == "") {
              // Json file exist but is currently empty
              print("jsonString is empty");
              return;
            }

            Map<String, dynamic> coordListMap = json.decode(jsonString);
            if (coordListMap != null) {
              // A json was indeed stored on the device
              CoordinatesList coordList =
                  CoordinatesList.fromJson(coordListMap);

              // Fill the widget list with the data read on the device mem.
              for (int i = 0; i < coordList.content.length; i++) {
                coordWidgetList.add(new CoordinatesTile(coordList.content[i]));
              }
            }
          }
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _getBody(){
    // If no coordinates added yet, nothing to display
    if (coordWidgetList.isEmpty) {
      return new Center(
          child: new Text("Nothing to display",
              style: TextStyle(fontSize: 20.0, color: Colors.black54)));
    }

    // Else, displays the list of the coordinates
    return new ListView(
        padding: new EdgeInsets.symmetric(vertical: 5.0),
        children: coordWidgetList);
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            backgroundColor: covoitULiegeColor,
            title: new Center(
                child: new Text("Covoit Uliege Dev. App",
                    style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)))),
        body: new Material(color: Colors.grey[200], child: _getBody()));
  }
}
