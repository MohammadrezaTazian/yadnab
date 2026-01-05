import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:education_app/injection_container.dart';
import 'package:education_app/features/auth/presentation/bloc/auth_bloc.dart';
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
          create: (_) => getIt<AuthBloc>(),
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
            initialRoute: AppRoutes.login,
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
