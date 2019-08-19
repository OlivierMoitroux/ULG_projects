// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginData _$LoginDataFromJson(Map<String, dynamic> json) {
  return LoginData(
      username: json['username'] as String,
      password: json['password'] as String);
}

Map<String, dynamic> _$LoginDataToJson(LoginData instance) => <String, dynamic>{
      'username': instance.username,
      'password': instance.password
    };
