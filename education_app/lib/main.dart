import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:education_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_state.dart';
import 'package:education_app/features/auth/presentation/pages/login_page.dart';
import 'package:education_app/features/settings/presentation/pages/settings_page.dart';
import 'package:education_app/features/upload/presentation/pages/image_upload_page.dart';
import 'package:education_app/shared/widgets/main_navigation.dart';
import 'package:education_app/shared/theme/app_theme.dart';
import 'package:education_app/core/routes/app_routes.dart';
import 'package:education_app/l10n/app_localizations.dart';
import 'package:education_app/core/config/config_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService().load();
  await setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (_) => getIt<SettingsBloc>()..add(LoadSettingsEvent()),
        ),
        BlocProvider(
          create: (_) => getIt<ProfileBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'Education App',
            navigatorKey: rootNavigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getLightTheme(settingsState.fontSize),
            darkTheme: AppTheme.getDarkTheme(settingsState.fontSize),
            themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(settingsState.languageCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              // گوش دادن سراسری به AuthUnauthenticated (خروج از حساب یا خطای ۴۰۱)
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthUnauthenticated) {
                    rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AuthCheckWrapper(),
            routes: {
              AppRoutes.login: (context) => const LoginPage(),
              AppRoutes.home: (context) => const MainNavigationPage(),
              AppRoutes.settings: (context) => const SettingsPage(),
              AppRoutes.upload: (context) => const ImageUploadPage(),
            },
          );
        },
      ),
    );
  }
}

/// ویجت دروازه ورود (Auth Gate) در startup
/// هنگام شروع برنامه با بررسی وضعیت احراز هویت کاربر را مستقیماً
/// به صفحه خانه یا لاگین هدایت می‌کند و مانع نمایش اشتباه صفحه لاگین می‌شود.
class AuthCheckWrapper extends StatefulWidget {
  const AuthCheckWrapper({super.key});

  @override
  State<AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<AuthCheckWrapper> {
  @override
  void initState() {
    super.initState();
    // بررسی وضعیت در صورتی که رویداد قبل از mount شدن لیسنر به پایان رسیده باشد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AuthBloc>().state;
      _navigateBasedOnState(state);
    });
  }

  void _navigateBasedOnState(AuthState state) {
    if (!mounted) return;
    if (state is AuthAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (state is AuthUnauthenticated || state is AuthError) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _navigateBasedOnState(state),
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
