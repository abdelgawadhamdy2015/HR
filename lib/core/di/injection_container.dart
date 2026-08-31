import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hr_attendance_app/core/storage/onboarding_storage.dart';
import 'package:hr_attendance_app/core/storage/token_storage.dart';
import 'package:hr_attendance_app/features/auth/data/datasources/auth_datasource.dart';

import '../network/dio_client.dart';

// Auth feature
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// Dashboard feature
import '../../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_stats.dart';
import '../../features/dashboard/domain/usecases/get_notifications.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';

// Employee feature
import '../../features/employee/data/datasources/employee_remote_data_source.dart';
import '../../features/employee/data/repositories/employee_repository_impl.dart';
import '../../features/employee/domain/repositories/employee_repository.dart';
import '../../features/employee/domain/usecases/get_employee_by_id.dart';
import '../../features/employee/domain/usecases/get_employee_month_details.dart';
import '../../features/employee/domain/usecases/get_employees.dart';
import '../../features/employee/domain/usecases/get_lateness.dart';
import '../../features/employee/domain/usecases/get_missions.dart';
import '../../features/employee/domain/usecases/get_permissions.dart';
import '../../features/employee/presentation/cubit/employee_details_cubit.dart';
import '../../features/employee/presentation/cubit/employee_list_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // --- Core ---
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // --- Auth feature ---
  // Auth Data Source / Fetcher Registration
  sl.registerLazySingleton<AuthDataSource>(() => AuthDataSource(sl<Dio>()));
  sl.registerLazySingleton<OnboardingStorage>(() => OnboardingStorage());
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
        datasource: sl<AuthDataSource>(), tokenStorage: sl<TokenStorage>()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Registered as lazy singleton so auth state remains consistent app-wide
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // --- Dashboard feature ---
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetDashboardStats(sl()));
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerFactory(
    () => DashboardCubit(getDashboardStats: sl(), getNotifications: sl()),
  );

  // --- Employee feature ---
  sl.registerLazySingleton<EmployeeRemoteDataSource>(
    () => EmployeeRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetEmployees(sl()));
  sl.registerLazySingleton(() => GetEmployeeById(sl()));
  sl.registerLazySingleton(() => GetEmployeeMonthDetails(sl()));
  sl.registerLazySingleton(() => GetMissions(sl()));
  sl.registerLazySingleton(() => GetPermissions(sl()));
  sl.registerLazySingleton(() => GetLateness(sl()));

  sl.registerFactory(() => EmployeeListCubit(getEmployees: sl()));

  // EmployeeDetailsCubit needs the employeeId at creation time -> factoryParam
  sl.registerFactoryParam<EmployeeDetailsCubit, int, void>(
    (employeeId, _) => EmployeeDetailsCubit(
      employeeId: employeeId,
      getEmployeeById: sl(),
      getEmployeeMonthDetails: sl(),
      getMissions: sl(),
      getPermissions: sl(),
      getLateness: sl(),
    ),
  );
}
