import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// Show the privacy policy in a pdf viewer
launchURLPrivPolicy(BuildContext context) async {
  const url = 'https://docs.google.com/document/d/1HFk_XrjjwyH4VYWR_BSsI7tLC8OEkesG3YgZsbi36Gw/edit?usp=sharing';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Navigator.pushNamed(context, "/privacy_policy_tmp");
    throw 'Could not launch $url';
  }
}