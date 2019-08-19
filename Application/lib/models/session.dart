import 'package:json_annotation/json_annotation.dart';


part 'session.g.dart';

/// A model class to represent a session with serialization support<br>
/// Warning: not included in the app. Let as an improvement.
@JsonSerializable()
class Session {
  // A token attributed by the server
  String token;
  // An expiration date
  DateTime expirationDateTime;

  Session(this.token, this.expirationDateTime);

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$CoordinatesToJson`.
  Map<String, dynamic> toJson() => _$SessionToJson(this);

  bool isExpired() => expirationDateTime.compareTo(DateTime.now()) < 0;

  /// Return token for authentication with the server
  String getToken() => token;

  /// Set a new token (extend old one or simply new one)
  void setNewToken(String newToken, DateTime newExpirationDate){
    this.token = newToken;
    this.expirationDateTime = newExpirationDate;
  }
}

/** Commands for automatic serialization: **/
/// flutter packages pub run build_runner build
/// flutter packages pub run build_runner watch
/// assert