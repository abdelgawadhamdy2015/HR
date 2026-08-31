import 'package:equatable/equatable.dart';

class MissionEntry extends Equatable {
  final int id;
  final DateTime date;
  final String reason;
  final String location;

  const MissionEntry({
    required this.id,
    required this.date,
    required this.reason,
    required this.location,
  });

  @override
  List<Object?> get props => [id, date, reason, location];
}
