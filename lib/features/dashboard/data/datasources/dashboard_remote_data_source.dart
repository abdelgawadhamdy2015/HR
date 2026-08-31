import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/app_notification_model.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getStats(DateTime date);
  Future<List<AppNotificationModel>> getNotifications();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;
  DashboardRemoteDataSourceImpl(this.dio);

  @override
  Future<DashboardStatsModel> getStats(DateTime date) async {
    try {
      final response = await dio.get(
        ApiConstants.dashboardStats,
        queryParameters: {'date': DateFormat('yyyy-MM-dd').format(date)},
      );
      return DashboardStatsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<AppNotificationModel>> getNotifications() async {
    try {
      final response = await dio.get(ApiConstants.notifications);
      final list = response.data as List<dynamic>;
      return list
          .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException();
    }
    if (e.response?.statusCode == 404) return NotFoundException();
    return ServerException(e.message ?? 'Server error');
  }
}
