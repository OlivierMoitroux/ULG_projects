import 'package:flutter/material.dart';
//import 'package:gps_tracer/utils/colors.dart';
import 'package:gps_tracer/models/habits.dart';
import 'package:gps_tracer/pages/travel_list/detail_page.dart';
import 'package:gps_tracer/pages/travel_list/StarRating.dart';
import 'package:auto_size_text/auto_size_text.dart';
//import 'package:sticky_header_list/sticky_header_list.dart';
import 'package:gps_tracer/network/network_utils.dart';
import 'dart:convert';
import 'package:gps_tracer/utils/colors.dart';
import 'package:geocoder/geocoder.dart' as geocoder;

class TravelHabitsPage extends StatefulWidget {
  TravelHabitsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TravelHabitsPageState createState() => _TravelHabitsPageState();
}


class _TravelHabitsPageState extends State<TravelHabitsPage> {

  List<HabitsData> travelsHabits;

  _TravelHabitsPageState(){
    NetworkUtilsSingleton.getInstance().getHabits().then((ServerReply reply){
      if(reply.isSuccess()){

        var jsonMap = json.decode(reply.content);
        print("Received habits from server ${json.decode(reply.content)}");
        _fromServerToAppFormalism(jsonMap["Habits"]).then((List<HabitsData> list){
          print("End of async formalism conversion");
          travelsHabits = list;
          setState((){});
        });

      }else{
        reply.content= "No data available";
        print(reply.content);
        travelsHabits = new List();
        setState((){});
      }

    });

  }

  void initState() {
    //travelsHabits = getTravelsHabits();

    super.initState();
  }

  Future<List<HabitsData>> _fromServerToAppFormalism(List habitsServerList) async {
    List<HabitsData> ret = new List();
    HabitsData hd;

    /// /!\ Geocoder can fail, known issue but not yet fixed by google.
    /// Can't do much about it -> use safety strings
    String startCity, startStreet = "";
    String endCity, endStreet = "";

    for (var habits in habitsServerList){



      List<double> startCoord = new List<double>.from(habits["startCoordinate"]);
      List<double> endCoord =  new List<double>.from(habits["endCoordinate"]);

      // Encode coordinates into real addresses
      geocoder.Address start, end;

      try {
        start = await _latLong2Address(startCoord);
        end = await _latLong2Address(endCoord);
        startCity = start.locality;
        startStreet = start.addressLine.split(",")[0];
        endCity = end.locality;
        endStreet = end.addressLine.split(",")[0];

      }
      catch(e){
        // Can't do anything about that
        startCity = "(" + startCoord[0].toString() + "," + startCoord[1].toString() + ")";
        startStreet = "";
        endCity = "(" + endCoord[0].toString() + "," + endCoord[1].toString() + ")";
        endStreet = "";
        print("[Error] geocoder did not work");
      }
      hd = HabitsData(
        startCity: startCity,
        startStreet: startStreet,
        startTime: habits["startTime"],
        endCity: endCity,
        endStreet: endStreet,
        endTime: habits["endTime"],
        weekDay: habits["weekday"],
        date: "Empty",
        timing: habits["timing"],
        locomotion: habits["locomotion"],
        scoring: habits["scoring"],
      );
      ret.add(hd);
    } // end of for


    print(json.encode(hd));
    return ret;
  }

  Future<geocoder.Address> _latLong2Address(List<double> latLong) async {
    geocoder.Coordinates coord = geocoder.Coordinates(latLong[0], latLong[1]);
    List<geocoder.Address> addresses = await geocoder.Geocoder.local.findAddressesFromCoordinates(coord);
    return addresses.first;
  }

  
  @override
  Widget build(BuildContext context) {

    ListTile makeListTile (HabitsData travelsHabit) => ListTile(

      contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 12.0),
      leading: Container( // To add image icon
        padding: EdgeInsets.only(left: 5.0),
        decoration: new BoxDecoration(
            border: new Border(
                right: new BorderSide(width: 1.0, color: Colors.white24))),
        child:
        new Tab(icon: new Image.asset("lib/images/"+travelsHabit.locomotion+".png", scale: 2.0, width: 48.0, height: 48.0,)),
      ),

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //Icon(Icons.place, size: 35.0,), // Or location_on
          Container(
            //color: Colors.blue,
            width: 110.0,
            height: 50.0,
            //alignment: Alignment.center,
            child: AutoSizeText(
              travelsHabit.startCity+"\n"+travelsHabit.startTime,
              style: TextStyle(fontSize: 19.0),
            ),
          ),
          Icon(Icons.forward, size: 35.0,color: Colors.black54,),
          Container(
            //color: Colors.red,
            width: 110.0,
            height: 50.0,
            padding: EdgeInsets.only(left: 5.0),
            //alignment: Alignment.center,
            child: AutoSizeText(
              travelsHabit.endCity+"\n"+travelsHabit.endTime,
              style: TextStyle(fontSize: 19.0),
            ),
          ),
        ],
      ),

      subtitle:
      Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: new StarRating(
          rating: travelsHabit.scoring,
          //onRatingChanged: (rating) => setState(() => this.rating = rating),
        ),
      ),

      trailing:
      Icon(Icons.keyboard_arrow_right, color: Colors.black45, size: 50.0),

      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailPage(travelsHabit)));//  travelsHabit: travelsHabit
      },
    );


    Card makeCard (HabitsData travelHabits) => Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: makeListTile(travelHabits),
      ),
    );


    Widget variableBody(){
      if(travelsHabits == null){
        return Center(
          child: Container(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(covoitULiegeColor),), // valueColor: AlwaysStoppedAnimation<Color>(Colors.white
          )
        );
      }else{
        if(travelsHabits.isEmpty){
          return Center(
            child: Container(
              child: new Text("No Data Available",
                style: TextStyle(
                    fontSize: 20.0
                ),
              ),
              alignment: FractionalOffset(0.5, 0.5),
            ),
          );
        }else{
          return Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: travelsHabits.length,
              itemBuilder: (BuildContext context, int index) {
                return makeCard(travelsHabits[index]);
              },
            ),
          );
        }
      }
    }

    final makeBody = variableBody();

    return Scaffold(
      backgroundColor: Colors.white,
      body: makeBody,
    );
  }
}


/// ********************************************
///           Temporary information
/// ********************************************
List<HabitsData> getTravelsHabits() {
  return [
    HabitsData(
        startCity: "Fléron",
        startStreet: "Rue Fonds de Forêt, 35",
        startTime: "7:30 +- 5'",
        endCity: "Juprelle",
        endStreet: "Rue du Tige, 34",
        endTime: "7:45 +- 15'",
        weekDay: "Monday",
        date: "22/04/19",
        timing: "15 min +- 10'",
        locomotion: "in_car",
        scoring: 1.0,
    ),
    HabitsData(
      startCity: "Fléron",
      startStreet: "Rue Fonds de Forêt, 35",
      startTime: "7:30 +- 5'",
      endCity: "Juprelle",
      endStreet: "Rue du Tige, 34",
      endTime: "7:45 +- 15'",
      weekDay: "Monday",
      date: "22/04/19",
      timing: "15 min +- 10'",
      locomotion: "in_bus",
      scoring: 2.0,
    ),
    HabitsData(
      startCity: "Woluwe-Saint-Lambert",
      startStreet: "Rue Fonds de Forêt, 35",
      startTime: "7:30 +- 5'",
      endCity: "Juprelle",
      endStreet: "Rue du Tige, 34",
      endTime: "7:45 +- 15'",
      weekDay: "Monday",
      date: "22/04/19",
      timing: "15 min +- 10'",
      locomotion: "on_foot",
      scoring: 2.77,
    ),
    HabitsData(
      startCity: "Fléron",
      startStreet: "Rue Fonds de Forêt, 35",
      startTime: "7:30 +- 5'",
      endCity: "Juprelle",
      endStreet: "Rue du Tige, 34",
      endTime: "7:45 +- 15'",
      weekDay: "Monday",
      date: "22/04/19",
      timing: "15 min +- 10'",
      locomotion: "in_car",
      scoring: 3.5,
    ),
    HabitsData(
      startCity: "Fléron",
      startStreet: "Rue Fonds de Forêt, 35",
      startTime: "7:30 +- 5'",
      endCity: "Juprelle",
      endStreet: "Rue du Tige, 34",
      endTime: "7:45 +- 15'",
      weekDay: "Monday",
      date: "22/04/19",
      timing: "15 min +- 10'",
      locomotion: "in_car",
      scoring: 1.0,
    ),
    HabitsData(
      startCity: "Fléron",
      startStreet: "Rue Fonds de Forêt, 35",
      startTime: "7:30 +- 5'",
      endCity: "Juprelle",
      endStreet: "Rue du Tige, 34",
      endTime: "7:45 +- 15'",
      weekDay: "Monday",
      date: "22/04/19",
      timing: "15 min +- 10'",
      locomotion: "in_bus",
      scoring: 2.0,
    ),
    HabitsData(
      startCity: "Woluwe-Saint-Lambert",
      startStreet: "Rue Fonds de Forêt, 35",
      startTime: "7:30 +- 5'",
      endCity: "Juprelle",
      endStreet: "Rue du Tige, 34",
      endTime: "7:45 +- 15'",
      weekDay: "Monday",
      date: "22/04/19",
      timing: "15 min +- 10'",
      locomotion: "on_foot",
      scoring: 2.77,
    ),
    HabitsData(
      startCity: "Fléron",
      startStreet: "Rue Fonds de Forêt, 35",
      startTime: "7:30 +- 5'",
      endCity: "Juprelle",
      endStreet: "Rue du Tige, 34",
      endTime: "7:45 +- 15'",
      weekDay: "Monday",
      date: "22/04/19",
      timing: "15 min +- 10'",
      locomotion: "in_car",
      scoring: 3.5,
    ),
  ];
}