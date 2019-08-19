import 'package:flutter/material.dart';
import 'package:gps_tracer/utils/colors.dart';
import 'package:gps_tracer/models/habits.dart';
import 'package:gps_tracer/pages/travel_list/StarRating.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DetailPage extends StatelessWidget {
  final HabitsData travelsHabit;
  // DetailPage({Key key, this.travelsHabit}) : super(key: key);

  DetailPage(this.travelsHabit);

  @override

  Widget build(BuildContext context) {

    /// Container for the top part of the page containing the information about day and appreciation.
    final topContent = Container(
      color: Color.fromRGBO(206, 206, 206, 0.2),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.17,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 4.0),
            Text(
              travelsHabit.weekDay,
              style: TextStyle(fontSize: 45, color: Colors.black54),
            ),
            SizedBox(height: 10.0),
            new StarRating(
              rating: travelsHabit.scoring,
            ),
          ],
        ),
      ),
    );

    /// Container for the locomotion Image
    final imageContent = Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.25,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("lib/images/"+travelsHabit.locomotion+".png"),
            fit: BoxFit.contain,

          ),
        )
    );

    /// Container for the bottom part containing the travels information
    final bottomContent = Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.45,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Icon(Icons.place, size: 70.0, color: Colors.black54,)
                ),
                Container(
                  padding: const EdgeInsets.all(15.0),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: AutoSizeText(
                    travelsHabit.startStreet+"\n"+travelsHabit.startCity+"\n"+travelsHabit.startTime,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    maxLines: 3,
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Icon(Icons.flag, size: 70.0, color: Colors.black54)
                ),
                Container(
                  padding: const EdgeInsets.all(15.0),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: AutoSizeText(
                    travelsHabit.endStreet+"\n"+travelsHabit.endCity+"\n"+travelsHabit.endTime,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    maxLines: 3,
                  ),
                )
              ],
            ),
            //SizedBox(height: 23.0),
            Row(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Icon(Icons.timer, size: 70.0, color: Colors.black54)
                ),
                Container(
                  padding: const EdgeInsets.all(15.0),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: AutoSizeText("Travel time:\n"+travelsHabit.timing,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                )
              ],
            )
          ],
        )
    );

    /// General Structure of the page
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: covoitULiegeColor,
        title: new Center(
            child: new Text("Detail of habit",
                style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
        ),
      ),
      body: Column(
        children: <Widget>[topContent, imageContent, bottomContent],
      ),
    );

  }
}
