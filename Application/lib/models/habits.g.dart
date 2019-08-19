// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitsData _$HabitsDataFromJson(Map<String, dynamic> json) {
  return HabitsData(
      startCity: json['startCity'] as String,
      startStreet: json['startStreet'] as String,
      startTime: json['startTime'] as String,
      endCity: json['endCity'] as String,
      endStreet: json['endStreet'] as String,
      endTime: json['endTime'] as String,
      weekDay: json['weekDay'] as String,
      date: json['date'] as String,
      timing: json['timing'] as String,
      locomotion: json['locomotion'] as String,
      scoring: (json['scoring'] as num)?.toDouble());
}

Map<String, dynamic> _$HabitsDataToJson(HabitsData instance) =>
    <String, dynamic>{
      'startCity': instance.startCity,
      'startStreet': instance.startStreet,
      'startTime': instance.startTime,
      'endCity': instance.endCity,
      'endStreet': instance.endStreet,
      'endTime': instance.endTime,
      'weekDay': instance.weekDay,
      'date': instance.date,
      'timing': instance.timing,
      'locomotion': instance.locomotion,
      'scoring': instance.scoring
    };
