import 'package:json_annotation/json_annotation.dart';
import 'package:gps_tracer/models/coordinates.dart';
import 'coordinates.dart';
import 'package:latlong/latlong.dart';
part 'trajectory.g.dart';


/// A model class to represent a trajectory with serialization support<br>
/// *Important notions:*<br>
///
///   * *Trajectory*: A collection of location points gathered in background from which useful information is extracted.
/// A trajectory links two stay points and represent what we can call a one-shot travel.<br>
///
///   * *Stay point*: A stay point is a particular point in space where the user stayed for more that T minutes in a geofence of radius R.
/// A stay point is the criterion to cut the flow of data in trajectories.
@JsonSerializable()
class Trajectory {

  static final Map<int, String> weekdays = {1:'monday', 2:'tuesday', 3:'wednesday', 4:'thursday', 5:'friday', 6:'saturday', 7:'sunday'};

  /// The stay point from where the travel/trajectory start
  Coordinates startStayPoint;
  /// The stay point destination
  Coordinates endStayPoint;

  /// Begin of the trajectory
  DateTime startTime;
  /// End of the trajectory
  DateTime endTime;

  /// Length of the trajectory
  double length;

  /// A map used to monitor the activity of the user and determine rawly the mean of travel. Not implemented.
  Map<String, double> activityStat = {'on_foot':0.0, 'in_vehicle':0.0, 'still':0.0, 'running':0.0, 'on_bicycle':0, 'unknown':0.0};

  /// The day of the travel. Not serialized.
  @JsonKey(ignore: true)
  String _day;

  /// The raw data used to build this trajectory. Not serialized.
  @JsonKey(ignore: true)
  List<Coordinates> _rawCoordList;


  /* --------------------------------------------------------------------- *
   *                         Constructors
   * ----------------------------------------------------------------------*/

  /// Default constructor: Only used for automatic serialization
  /// -------------------
  Trajectory(this.startStayPoint, this.endStayPoint, this.startTime, this.endTime, this.length, this.activityStat);

  /// Build a new trajectory, ready to be sent to the server after call.
  ///
  ///   * *startStayPoint*: center of start geofence
  ///   * *coordList*: CoordinatesList of all the data used to build this trajectory
  ///   * *endStayPoint*: center of end geofence
  ///   * *removeBias*: optional, remove the bias that happen when waiting T minutes to set new geofence. Bias concerned destination location, arrival time and length of trajectory
  ///   * *smoothing*: optional, perform some processing of the raw coordinates to smooth the interpolation of the points
  Trajectory.build(Coordinates startStayPoint, CoordinatesList coordList, Coordinates endStayPoint, {bool removeBias: false, bool smoothing = false}) {

    DateTime exitGeofenceTime;

    // First data outside geofence
    if (coordList.content.length > 1)
      exitGeofenceTime= coordList.content[1].dateTime;
    else {
      // Should not happen
      exitGeofenceTime = coordList.content[0].dateTime;
    }
    _rawCoordList = smoothing?smoothTrajectory(coordList.content):coordList.content;
    this.startStayPoint = startStayPoint;
    this.startTime = exitGeofenceTime;
    this.endStayPoint = endStayPoint;
    this.endTime = endStayPoint.dateTime;
    this._day = _getDayOfWeek(exitGeofenceTime);

    if (removeBias){
      // Do processing on raw coordinates
      // Not implemented, let as an improvement
    }
    if (smoothing){
      // Do smoothing on raw coordinates
      // Not implemented, let as an improvement
    }

    // update the length of the trajectory
    processData(removeBias, smoothing);
  }

  /// Should be constructed manually with setters and adders. It is the programmer
  /// responsibility to ensure every fields are set correctly before export.
  Trajectory.empty(){
    _rawCoordList = new List();
  }

  /* --------------------------------------------------------------------- *
   *                         JSON serialization
   * ----------------------------------------------------------------------*/

  factory Trajectory.fromJson(Map<String, dynamic> json) => _$TrajectoryFromJson(json);
  Map<String, dynamic> toJson() => _$TrajectoryToJson(this);

  /* --------------------------------------------------------------------- *
   *                              Utils
   * ----------------------------------------------------------------------*/

  List<Coordinates> smoothTrajectory(List<Coordinates> coorList){
    // Not implemented. See LatLong package for more info.
  }

  void processData(removeBiasArrival,bool smoothing){
    if (removeBiasArrival){
      endStayPoint = _removeBiasEndStayPoint_CleanCoordList();
    }
    if (smoothing){
      _rawCoordList = smoothTrajectory(_rawCoordList);
    }
    _computeLengthTrajectory();
  }


  /* --------------------------------------------------------------------- *
   *                              Getters
   * ----------------------------------------------------------------------*/
  DateTime getStartTime() => startTime;
  DateTime getEndTime() => endTime;
  Coordinates getStartStayPoint() => startStayPoint;
  Coordinates getEndStayPoint() => endStayPoint;
  double getLength() => length;
  String getDayOfWeek() => _day;

  /* --------------------------------------------------------------------- *
   *                              Setters
   * ----------------------------------------------------------------------*/
  void setStartTime(DateTime startTime){
    this.startTime = startTime;
  }
  void setEndTime(DateTime endTime, bool removeBias){
    this.endTime = removeBias?_removeTimeBiasArrival(endTime):endTime;
  }

  void setStartStayPoint(Coordinates stayPoint, DateTime timeStamp) {

    this._day = _getDayOfWeek(timeStamp);
    this.startStayPoint = stayPoint;
  }

  void setEndStayPoint(Coordinates stayPoint){
    this.endStayPoint = stayPoint;
  }

  void setRawDataPoints(CoordinatesList rawCoordinates){
    this._rawCoordList.clear();
    this._rawCoordList = rawCoordinates.content;
  }


  /* --------------------------------------------------------------------- *
   *                               Private
   * ----------------------------------------------------------------------*/

  String _getDayOfWeek(DateTime date) {
    if (date == null){
      throw("date parameter is null");
    }
    return Trajectory.weekdays[date.weekday];
  }

  /// Use content of _rawCoordList to compute the length of the trajectory
  void _computeLengthTrajectory(){
    int i;
    length = 0.0;
    if (_rawCoordList == null){
      throw("coord list is null");
    }

    // "Vincenty" algorithm, default to round to integer
    Distance distance = new Distance();

    if(_rawCoordList.length > 1) {
      for (i=1; i < _rawCoordList.length; i++){
        length += distance(
            new LatLng(_rawCoordList[i-1].latitude, _rawCoordList[i-1].longitude),
            new LatLng(_rawCoordList[i].latitude, _rawCoordList[i].longitude)
        );
      }
    }
  }

  /// Remove the bias on the end stay point resulting from the waiting of
  /// T minutes to determine wether we are at the destination stay point or not.
  /// The active tracking creates data eventhough we are at destination.
  /// Thiss impact lenght, time and location of arrivak.
  ///
  /// Warning: this is not implemented (see report)
  Coordinates _removeBiasEndStayPoint_CleanCoordList(){
    this.endTime = _removeTimeBiasArrival(_rawCoordList[_rawCoordList.length -1].dateTime);
  }

  /// Temporary implementation. Not valid in every circumstances.
  ///
  /// Consider not implemented (see report).
  DateTime _removeTimeBiasArrival(DateTime lastRecorded){
    return lastRecorded.subtract(Duration(minutes: 20));
  }
}

/// A model class to represent a pool of trajectories with serialization support<br>
@JsonSerializable()
class PoolTrajectories {
  List<Trajectory> trajectories;

  PoolTrajectories(){
   this.trajectories = new List();
  }

  factory PoolTrajectories.fromJson(Map<String, dynamic> json) => _$PoolTrajectoriesFromJson(json);
  Map<String, dynamic> toJson() => _$PoolTrajectoriesToJson(this);

  void add(Trajectory traj) {
    trajectories.add(traj);
  }

  void clear(){
    trajectories.clear();
  }

  bool isEmpty() => trajectories.isEmpty;

  int getSize() => trajectories.length;

}

/** Commands for automatic serialization: **/
/// flutter packages pub run build_runner build
/// flutter packages pub run build_runner watch
/// assert