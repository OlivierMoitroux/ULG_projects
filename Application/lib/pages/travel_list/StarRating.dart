import 'package:flutter/material.dart';
import 'package:gps_tracer/utils/colors.dart';


class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final Color color;

  StarRating({this.starCount = 4, this.rating = .0, this.color});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: covoitULiegeColor,
        size: 32.0,
      );
    }
    else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: covoitULiegeColor,
        size: 32.0,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: covoitULiegeColor,
        size: 32.0,
      );
    }

    return new InkResponse(
      child: icon,
    );

  }

  @override
  Widget build(BuildContext context) {
    return new Row(mainAxisAlignment: MainAxisAlignment.center, children: new List.generate(starCount, (index) => buildStar(context, index)));
  }
}