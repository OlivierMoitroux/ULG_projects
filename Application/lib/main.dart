import 'package:flutter/material.dart';
import 'package:gps_tracer/pages/root_page.dart';
import 'package:gps_tracer/utils/routing.dart' as routing;
import 'package:gps_tracer/utils/colors.dart' as myColors;

/// This is the main entry point of the application
///
/// *To compile the app:* flutter build apk --debug
void main() {
  runApp(new MyApp());
}

/// Main entry point of code. Initialise a RootPage.<br>
/// Define themes and colors here
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Covoit ULiège Dev.',
        home: new RootPage(),
        theme: ThemeData(
          backgroundColor: myColors.covoitULiegeColor,
          textTheme: TextTheme(
            body1: TextStyle(color: Colors.black54)
          ),
          buttonColor: myColors.covoitULiegeColor,
          dividerColor: Colors.black54,

        ),
        routes: routing.routes,
    );
  }
}