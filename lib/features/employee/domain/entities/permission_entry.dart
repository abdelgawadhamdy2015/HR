import 'package:equatable/equatable.dart';

class PermissionEntry extends Equatable {
  final int id;
  final DateTime date;
  final String from;
  final String to;
  final String reason;

  const PermissionEntry({
    required this.id,
    required this.date,
    required this.from,
    required this.to,
    required this.reason,
  });

  @override
  List<Object?> get props => [id, date, from, to, reason];
}
