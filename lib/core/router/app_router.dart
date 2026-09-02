import 'package:go_router/go_router.dart';
import 'package:hr_attendance_app/features/attendance/presentation/screens/attendance_actions_screen.dart';
import 'package:hr_attendance_app/features/onboarding/presentation/screens/onboarding_screen.dart';

import '../storage/onboarding_storage.dart';
import '../widgets/splash_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/employee/presentation/pages/employee_details_page.dart';
import '../../features/employee/presentation/pages/employee_list_page.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter._();

  static GoRouter build({
    required AuthCubit authCubit,
    required OnboardingStorage onboardingStorage,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) async {
        final loc = state.matchedLocation;
        final authStatus = authCubit.state.status;

        // Session restore still in flight -> park on splash.
        if (authStatus == AuthStatus.initial ||
            authStatus == AuthStatus.loading) {
          return loc == AppRoutes.splash ? null : AppRoutes.splash;
        }

        final authenticated = authStatus == AuthStatus.authenticated;
        final onAuthScreen =
            loc == AppRoutes.login || loc == AppRoutes.register;

        if (!authenticated) {
          final onboardingDone = await onboardingStorage.isComplete();
          if (!onboardingDone) {
            return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
          }
          return onAuthScreen ? null : AppRoutes.login;
        }

        // Authenticated: never let them sit on splash/onboarding/login/register.
        if (onAuthScreen ||
            loc == AppRoutes.splash ||
            loc == AppRoutes.onboarding) {
          return AppRoutes.home;
        }
        return null;
      },
      routes: [
        GoRoute(
            path: AppRoutes.splash,
            builder: (context, state) => const SplashPage()),
        GoRoute(
            path: AppRoutes.onboarding,
            builder: (context, state) => const OnboardingPage()),
        GoRoute(
            path: AppRoutes.login,
            builder: (context, state) => const LoginScreen()),
        GoRoute(
            path: AppRoutes.register,
            builder: (context, state) => const RegisterScreen()),
        GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const DashboardPage()),
        GoRoute(
            path: AppRoutes.employees,
            builder: (context, state) => const EmployeeListPage()),
        GoRoute(
          path: '/employees/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return EmployeeDetailsPage(employeeId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.attendanceActions,
          builder: (context, state) {
            final tab =
                int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
            return AttendanceActionsScreen(initialTabIndex: tab);
          },
        ),
      ],
    );
  }
}
