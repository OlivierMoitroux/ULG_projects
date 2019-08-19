import 'package:flutter/material.dart';
import 'package:gps_tracer/store/shared_pref.dart' as shared_pref;

/// Home screen. Such page would be useful to propose to the user its next travel and launch the covoit Uliège app.
/// Let as an improvement and not asked by the client anyway. This page still have sense though.
class HomeBody extends StatefulWidget {

  @override
  State createState() => new HomeBodyState();

}

class HomeBodyState extends State<HomeBody> {

  String _content = "";

  HomeBodyState();

  @override
  void initState() {
    super.initState();
    String msg = "allah";
    shared_pref.Settings.getSwitchValue("LocationON", true).then((bool onValue){
      if (onValue == true) {
        msg = "No recent travel to propose";
      }
      else{
        msg = "Please, turn on location in the app settings to detect automatically your travels";
      }
      setState((){
        print("[root_page] iniState/setState called");
        _content = msg;
      });
    });

  }
  /// --------------------------------------------------------------------------
  ///                               Widget building
  ///                               ***************
  /// --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // List view required to allow scrollong if screen is too small to fit the content.
    // @see also Expanded
    // @See also SingleChildScrollView
    return new ListView(
        // Destroy the axis alignement of the column though
        padding: EdgeInsets.only(top: 40.0, left: 24.0, right: 24.0),
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              /// GUI for background stuff

              new Text("Welcome on Covoit ULiege Dev.", style: TextStyle(fontSize: 32.0, color: Colors.black54),
                  textAlign: TextAlign.center),
              new Container(child: new Text(_content, style: TextStyle(fontSize: 25.0, color: Colors.black54),
                  textAlign: TextAlign.center),)
            ]
    ),
        ]);
  }
}
