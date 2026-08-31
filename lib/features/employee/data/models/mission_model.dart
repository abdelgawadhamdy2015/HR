import '../../domain/entities/mission_entry.dart';

class MissionModel extends MissionEntry {
  const MissionModel({
    required super.id,
    required super.date,
    required super.reason,
    required super.location,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      reason: json['reason'] as String,
      location: json['location'] as String,
    );
  }
}
