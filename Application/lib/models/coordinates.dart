import 'package:json_annotation/json_annotation.dart';

/// This allows the `Coordinates` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'coordinates.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.

/// A model class to represent coordinates with serialization support
@JsonSerializable()
class Coordinates {
  Coordinates(this.latitude, this.longitude, this.dateTime, this.activity);

  final double latitude;
  final double longitude;
  final DateTime dateTime;
  final String activity;

  /// A necessary factory constructor for creating a new Coordinates instance
  /// from a map. Pass the map to the generated `_$CoordiantesFromJson` constructor.
  /// The constructor is named after the source class, in this case Coordinates.
  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$CoordinatesToJson`.
  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);
}

/// A model class to represent a list of coordinates with serialization support
@JsonSerializable()
class CoordinatesList {
  DateTime beginRecordDateTime; // final

  DateTime endRecordDateTime;

  List<Coordinates> content;

  CoordinatesList(this.beginRecordDateTime, this.endRecordDateTime, this.content);
  CoordinatesList.empty();

  /// Add a new coordinates to the list
  void add(Coordinates newCoord){
    content.add(newCoord);
  }

  int getSize() => content.length;

  bool isEmpty() => content.isEmpty;

  factory CoordinatesList.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesListFromJson(json);

  Map<String, dynamic> toJson() => _$CoordinatesListToJson(this);
}


/** Commands for automatic serialization: **/
/// flutter packages pub run build_runner build
/// flutter packages pub run build_runner watch
/// assert
