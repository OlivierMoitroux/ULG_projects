import 'package:flutter/material.dart';
import 'package:gps_tracer/utils/colors.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

/// Simple text page (*temporary* content)
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        backgroundColor: covoitULiegeColor,
      ),
      body: new Container(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        child: SingleChildScrollView(
          child: Html(
            data: """
    <h1>An application designed to improve your life style</h1>
    <p>Effective date: January 23, 2019</p>
    
    <h2>The concept of Covoit Uliege:</h2>
    <p>
    <i>"Experimenting a new way of transport in Liège by bringing people together to share a ride !"</i>
    <br>Back in 2015, the Covoit Uliege concept was launched with the idea of bringing closer people to share a ride and alleviate the traffic jams around the campus of the University. 
    Counting already a data base of more than 4000 users, the service allowed successfully  many students to get to their auditoriums, especially in periods of public transport strikes. 
    The concept also subscribe like a step forward in the energetic transition politic of the University. While helping many peoples, the service is completely free and developed by students in the context of their studies. 
    Let's experiment a new way of transport in Liège !</p>
    
    <h2>The goal of this application:</h2>
    
    <p>
    <i>"Car sharing made easier than ever before."</i>
    <br><br>
    While this application is developed to enhance the service of Covoit Uliege, it should be noted that it is not an official release of the application of the Covoit Uliege web platform but rather an experimental project of students asked to enhance the user experience of the service.
    In this way, we were asked to enhance the already existing platform so that users shouldn't need to enter their frequent travel manually anymore. Basically, the idea is to develop an application that can detect and analyze the travel habits of the users in background in order to predict their next travel automatically. 
    </p>
    <h2>Who are we ?</h2>
    
    <p>
    Behind the Covoit Uliege Dev App is a team of students in computer Engineering striving to bring a new approach on the car sharing industry and enhance the quality of the already existing service.  The protection of your data is a priority for us and is deeply written in our mind.
    By accepting to use this app, you help us testing and correcting bugs in this trial platform. But more than that, you contribute on your own to the development of the next generation of car sharing applications. For this reason, the developer team would like to exprimate their thanks and hope, perhaps one day, to share a ride with you !
    </p>
  """,
            //Optional parameters:
            padding: EdgeInsets.all(8.0),
            onLinkTap: (url) {
              print("Opening $url...");
            },
            customRender: (node, children) {
              if (node is dom.Element) {
                switch (node.localName) {
                  case "custom_tag":
                    return Column(children: children);
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
