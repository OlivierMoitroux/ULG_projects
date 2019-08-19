import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gps_tracer/store/file_manager.dart';
import 'package:gps_tracer/models/coordinates.dart';
import 'package:gps_tracer/models/trajectory.dart';
import 'package:gps_tracer/models/trajectory.dart';
import 'package:gps_tracer/utils/colors.dart';

/// The Coordinates class represents an element of the displayed coordinates list
class TrajectoryTile extends StatelessWidget {
  final Trajectory _trajectory;

  TrajectoryTile(this._trajectory);

  @override
  Widget build(BuildContext context) {

    final int _dayStart = _trajectory.startTime.day;
    final int _monthStart = _trajectory.startTime.month;
    final int _yearStart = _trajectory.startTime.year;
    final int _hourStart = _trajectory.startTime.hour;
    final int _minuteStart = _trajectory.startTime.minute;
    final int _secondStart = _trajectory.startTime.second;

    final int _dayEnd = _trajectory.endTime.day;
    final int _monthEnd = _trajectory.endTime.month;
    final int _yearEnd = _trajectory.endTime.year;
    final int _hourEnd = _trajectory.endTime.hour;
    final int _minuteEnd = _trajectory.endTime.minute;
    final int _secondEnd = _trajectory.endTime.second;

    return new Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 1.0),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        alignment: Alignment.center,
        child:

        new Row(
            //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(child:
              new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text("Start lat: ${_trajectory.startStayPoint.latitude}"),
                    new Text("Start Long: ${_trajectory.startStayPoint.longitude}"),
                    new Text("Start Date: $_dayStart/$_monthStart/$_yearStart"),
                    new Text("Start Hour: $_hourStart:$_minuteStart:$_secondStart"),
                    new Text ("Stat day/end: $_dayStart/$_dayEnd "),
                  ])),
              Expanded(child:
              new Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Text("End lat: ${_trajectory.endStayPoint.latitude}"),
                    new Text("End Long: ${_trajectory.endStayPoint.longitude}"),
                    new Text("End Date: $_dayEnd/$_monthEnd/$_yearEnd"),
                    new Text("End Hour: $_hourEnd:$_minuteEnd:$_secondEnd"),
                    new Text("Length: ${_trajectory.length} m"),

                  ]))
            ],
        )
        );
  }
}

/// The coordinates list page in the app:
class TrajectoryListPage extends StatefulWidget {
  // Storage is used to retrieve the coordinates list that is stored on the
  // device memory
  final JSONCoordinatesStorage storage = new JSONCoordinatesStorage();
  @override
  State createState() => new TrajectoryListPageState();
}

class TrajectoryListPageState extends State<TrajectoryListPage> {
  // List of CoordinatesTile widget to display the stored Coordinates and
  // associated data on the device memory
  List<TrajectoryTile> trajectoryWidgetList = new List();

  @override
  void initState() {
    super.initState();
    try {
      PoolTrajectoriesStorageSingleton.getInstance().readPoolTrajectories().then((String jsonString) {
        setState(() {
          // Required to avoid bug in the display
          trajectoryWidgetList.clear();
          if (jsonString != null) {
            print("TrajectoryList = $jsonString");

            if (jsonString == "") {
              // Json file exist but is currently empty
              print("jsonString is empty");
              return;
            }

            Map<String, dynamic> trajectoryListMap = json.decode(jsonString);
            if (trajectoryListMap != null) {
              // A json was indeed stored on the device
              PoolTrajectories trajectoryList = PoolTrajectories.fromJson(trajectoryListMap);

              // Fill the widget list with the data read on the device mem.
              for (int i = 0; i < trajectoryList.getSize(); i++) {
                trajectoryWidgetList.add(new TrajectoryTile(trajectoryList.trajectories[i]));
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
    if (trajectoryWidgetList.isEmpty) {
      return new Center(
          child: new Text("Nothing to display",
              style: TextStyle(fontSize: 20.0, color: Colors.black54)));
    }

    // Else, displays the list of the coordinates
    return new ListView(
        padding: new EdgeInsets.symmetric(vertical: 5.0),
        children: trajectoryWidgetList);
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
