// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trajectory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trajectory _$TrajectoryFromJson(Map<String, dynamic> json) {
  return Trajectory(
      json['startStayPoint'] == null
          ? null
          : Coordinates.fromJson(
              json['startStayPoint'] as Map<String, dynamic>),
      json['endStayPoint'] == null
          ? null
          : Coordinates.fromJson(json['endStayPoint'] as Map<String, dynamic>),
      json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      (json['length'] as num)?.toDouble(),
      (json['activityStat'] as Map<String, dynamic>)?.map(
        (k, e) => MapEntry(k, (e as num)?.toDouble()),
      ));
}

Map<String, dynamic> _$TrajectoryToJson(Trajectory instance) =>
    <String, dynamic>{
      'startStayPoint': instance.startStayPoint,
      'endStayPoint': instance.endStayPoint,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'length': instance.length,
      'activityStat': instance.activityStat
    };

PoolTrajectories _$PoolTrajectoriesFromJson(Map<String, dynamic> json) {
  return PoolTrajectories()
    ..trajectories = (json['trajectories'] as List)
        ?.map((e) =>
            e == null ? null : Trajectory.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$PoolTrajectoriesToJson(PoolTrajectories instance) =>
    <String, dynamic>{'trajectories': instance.trajectories};
