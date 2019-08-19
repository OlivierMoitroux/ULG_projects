import 'package:json_annotation/json_annotation.dart';

part 'habits.g.dart';

/// A model class to represent habits with serialization support
@JsonSerializable()
class HabitsData{
  String startCity;
  String startStreet;
  String startTime;
  String endCity;
  String endStreet;
  String endTime;
  String weekDay;
  String date;
  String timing;
  String locomotion; /// in_car, in_bus, on_foot
  double scoring;

  HabitsData({this.startCity, this.startStreet, this.startTime, this.endCity, this.endStreet, this.endTime, this.weekDay, this.date, this.timing, this.locomotion, this.scoring});
  HabitsData.empty();

  factory HabitsData.fromJson(Map<String, dynamic> json) => _$HabitsDataFromJson(json);
  Map<String, dynamic> toJson() => _$HabitsDataToJson(this);
}

/** Commands for automatic serialization: **/
/// flutter packages pub run build_runner build
/// flutter packages pub run build_runner watch