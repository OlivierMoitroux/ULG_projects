import 'package:json_annotation/json_annotation.dart';

part 'register_data.g.dart';

/// A model class to represent the data of the signup form with serialization support
@JsonSerializable()
class RegisterData{
  String username;
  String password;

  // Don't include in json export
  @JsonKey(ignore: true)
  String passwordConf;

  String email;
  String homeAddress;
  String homeZip;
  String homeCountry;
  String workAddress;
  String workZip;
  String workCountry;
  String work;

  RegisterData({this.username, this.password, this.passwordConf, this.email, this.homeAddress, this.homeZip, this.homeCountry, this.workAddress, this.workZip, this.workCountry, this.work});
  RegisterData.empty();

  factory RegisterData.fromJson(Map<String, dynamic> json) =>
      _$RegisterDataFromJson(json);


  Map<String, dynamic> toJson() => _$RegisterDataToJson(this);

}

/** Commands for automatic serialization: **/
/// flutter packages pub run build_runner build
/// flutter packages pub run build_runner watch
/// assert
