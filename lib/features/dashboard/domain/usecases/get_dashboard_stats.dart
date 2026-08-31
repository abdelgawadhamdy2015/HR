import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardStats implements UseCase<DashboardStats, DateTime> {
  final DashboardRepository repository;
  GetDashboardStats(this.repository);

  @override
  Future<Result<DashboardStats>> call(DateTime params) {
    return repository.getStats(params);
  }
}
