// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) {
  return Session(
      json['token'] as String,
      json['expirationDateTime'] == null
          ? null
          : DateTime.parse(json['expirationDateTime'] as String));
}

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'token': instance.token,
      'expirationDateTime': instance.expirationDateTime?.toIso8601String()
    };
