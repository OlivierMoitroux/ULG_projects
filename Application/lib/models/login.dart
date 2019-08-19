import 'package:json_annotation/json_annotation.dart';

part 'login.g.dart';


/// A model class to represent the data of the login form with serialization support
@JsonSerializable()
class LoginData {
  String username = '';
  String password = '';

  LoginData({this.username, this.password});
  /// Named constructor
  LoginData.empty();

  factory LoginData.fromJson(Map<String, dynamic> json) => _$LoginDataFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}

/** Commands for automatic serialization: **/
/// flutter packages pub run build_runner build
/// flutter packages pub run build_runner watch
/// assert