import '../../../../core/utils/result.dart';
import '../entities/app_notification.dart';
import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<Result<DashboardStats>> getStats(DateTime date);
  Future<Result<List<AppNotification>>> getNotifications();
}
