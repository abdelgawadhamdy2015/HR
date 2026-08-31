import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.date,
    required super.totalEmployees,
    required super.presentToday,
    required super.lateToday,
    required super.onMission,
    required super.onLeave,
    required super.absentToday,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      date: DateTime.parse(json['date'] as String),
      totalEmployees: json['totalEmployees'] as int,
      presentToday: json['presentToday'] as int,
      lateToday: json['lateToday'] as int,
      onMission: json['onMission'] as int,
      onLeave: json['onLeave'] as int,
      absentToday: json['absentToday'] as int,
    );
  }
}
