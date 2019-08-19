// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterData _$RegisterDataFromJson(Map<String, dynamic> json) {
  return RegisterData(
      username: json['username'] as String,
      password: json['password'] as String,
      // passwordConf: json['passwordConf'] as String,
      email: json['email'] as String,
      homeAddress: json['homeAddress'] as String,
      homeZip: json['homeZip'] as String,
      homeCountry: json['homeCountry'] as String,
      workAddress: json['workAddress'] as String,
      workZip: json['workZip'] as String,
      workCountry: json['workCountry'] as String,
      work: json['work'] as String);
}

Map<String, dynamic> _$RegisterDataToJson(RegisterData instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      // 'passwordConf': instance.passwordConf,
      'email': instance.email,
      'homeAddress': instance.homeAddress,
      'homeZip': instance.homeZip,
      'homeCountry': instance.homeCountry,
      'workAddress': instance.workAddress,
      'workZip': instance.workZip,
      'workCountry': instance.workCountry,
      'work': instance.work
    };
