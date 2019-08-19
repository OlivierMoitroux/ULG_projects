import 'package:flutter/material.dart';

import 'package:gps_tracer/utils/colors.dart';
import 'home_body.dart';
import 'package:gps_tracer/pages/settings/settings_page.dart' as settings;
import 'package:gps_tracer/network/network_utils.dart';
import 'package:gps_tracer/pages/travel_list/travel_habits_page.dart' as travel_habits;

/// The home page with the bottom navigation bar to build
/// HomeBody, TravelListBody or SettingsBody widgets. This page welcome the user on home by default after login.
class HomePage extends StatefulWidget {

  final VoidCallback onSignedOut;

  // Constructor
  HomePage({this.onSignedOut});

  @override
  State createState(){
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _navigationIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _signOut() async{
    try{
      ServerReply reply = await NetworkUtilsSingleton.getInstance().logout();
      if (reply.isSuccess()) {
        // log out
        widget.onSignedOut();
      }
      else {
        // Alert box or whatever
        print(reply.content);
      }
    }
    catch(e){
      print(e);
    }
  }

  /// Returns the body to display following the value of the navigation index
  Widget _getBody() {
    switch (_navigationIndex) {

      case 1:
        return new travel_habits.TravelHabitsPage();

      case 2:
        return new settings.SettingsPage(onSignOutClick: _signOut); // widget.auth, widget.onSignedOut

      default:
        // Home
        return new HomeBody();
    }
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
            body: new Material(color: Colors.grey[200], child: _getBody()),
            bottomNavigationBar: new BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                fixedColor: covoitULiegeColor,
                currentIndex: _navigationIndex,
                // On tap, changes the navigation index (i.e. the body to display)
                onTap: (int index) => setState(() {
                      _navigationIndex = index;
                    }),
                items: <BottomNavigationBarItem>[
                  // Home
                  new BottomNavigationBarItem(
                      title: new Text("Home"),
                      icon: new IconButton(
                          icon: Icon(Icons.home, color: Colors.black54),
                          iconSize: 35.0),

                  ),
                  //  Travel habits list
                  new BottomNavigationBarItem(
                      title: new Text("Travel Habits"),
                      icon: new IconButton(
                          icon: Icon(Icons.directions_car, color: Colors.black54),
                          iconSize: 35.0)
                  ),
                  // Settings
                  new BottomNavigationBarItem(
                      title: new Text("Settings"),
                      icon: new IconButton(
                          icon: Icon(Icons.settings, color: Colors.black54),
                          iconSize: 35.0)),

                ]));
  }
}
