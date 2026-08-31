import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/app_notification.dart';
import '../repositories/dashboard_repository.dart';

class GetNotifications implements UseCase<List<AppNotification>, NoParams> {
  final DashboardRepository repository;
  GetNotifications(this.repository);

  @override
  Future<Result<List<AppNotification>>> call(NoParams params) {
    return repository.getNotifications();
  }
}
