import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/storage/onboarding_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  // Fire-and-forget: the router listens to AuthCubit's stream and redirects
  // automatically once this resolves to authenticated/unauthenticated.
  sl<AuthCubit>().restoreSession();
  runApp(const HRAttendanceApp());
}

class HRAttendanceApp extends StatelessWidget {
  const HRAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.build(
      authCubit: sl<AuthCubit>(),
      onboardingStorage: sl<OnboardingStorage>(),
    );

    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: MaterialApp.router(
        title: 'شؤون العاملين',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
      ),
    );
  }
}
