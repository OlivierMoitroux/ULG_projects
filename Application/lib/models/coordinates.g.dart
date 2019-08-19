// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coordinates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coordinates _$CoordinatesFromJson(Map<String, dynamic> json) {
  return Coordinates(
      (json['latitude'] as num)?.toDouble(),
      (json['longitude'] as num)?.toDouble(),
      json['dateTime'] == null
          ? null
          : DateTime.parse(json['dateTime'] as String),
      json['activity'] as String);
}

Map<String, dynamic> _$CoordinatesToJson(Coordinates instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'dateTime': instance.dateTime?.toIso8601String(),
      'activity': instance.activity
    };

CoordinatesList _$CoordinatesListFromJson(Map<String, dynamic> json) {
  return CoordinatesList(
      json['beginRecordDateTime'] == null
          ? null
          : DateTime.parse(json['beginRecordDateTime'] as String),
      json['endRecordDateTime'] == null
          ? null
          : DateTime.parse(json['endRecordDateTime'] as String),
      (json['content'] as List)
          ?.map((e) => e == null
              ? null
              : Coordinates.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$CoordinatesListToJson(CoordinatesList instance) =>
    <String, dynamic>{
      'beginRecordDateTime': instance.beginRecordDateTime?.toIso8601String(),
      'endRecordDateTime': instance.endRecordDateTime?.toIso8601String(),
      'content': instance.content
    };
