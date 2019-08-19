import 'package:flutter/material.dart';
import 'package:gps_tracer/utils/colors.dart';

/// Simple text page
class LoremPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lorem Ipsum"),
          backgroundColor: covoitULiegeColor,
        ),
        body: new Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: new Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum")));
  }
}