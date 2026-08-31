import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final DateTime date;
  final int totalEmployees;
  final int presentToday;
  final int lateToday;
  final int onMission;
  final int onLeave;
  final int absentToday;

  const DashboardStats({
    required this.date,
    required this.totalEmployees,
    required this.presentToday,
    required this.lateToday,
    required this.onMission,
    required this.onLeave,
    required this.absentToday,
  });

  @override
  List<Object?> get props =>
      [date, totalEmployees, presentToday, lateToday, onMission, onLeave, absentToday];
}
