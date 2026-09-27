import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/core/constants/storage_constants.dart';
import 'package:education_app/core/services/api_service.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_state.dart';
import 'package:education_app/shared/storage/shared_preferences_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferencesService prefsService;
  final ApiService apiService;

  bool _isAuthenticated = false;

  SettingsBloc({
    required this.prefsService,
    required this.apiService,
  }) : super(const SettingsState()) {
    on<LoadGuestSettingsEvent>(_onLoadGuestSettings);
    on<LoadUserSettingsEvent>(_onLoadUserSettings);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<ChangeFontSizeEvent>(_onChangeFontSize);
  }

  Future<void> _onLoadGuestSettings(
    LoadGuestSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    _isAuthenticated = false;

    final isDark =
        prefsService.getBool(StorageConstants.guestTheme) ?? false;

    final language =
        prefsService.getString(StorageConstants.guestLanguage) ?? 'fa';

    final fontSize =
        prefsService.getInt(StorageConstants.guestFontSize)?.toDouble() ??
            14.0;

    emit(
      state.copyWith(
        isDarkMode: isDark,
        languageCode: language,
        fontSize: fontSize,
      ),
    );
  }

  Future<void> _onLoadUserSettings(
    LoadUserSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    _isAuthenticated = true;

    try {
      final settings = await apiService.getSettings();

      emit(
        state.copyWith(
          isDarkMode: settings.theme == 'Dark',
          languageCode: settings.language,
          fontSize: settings.fontSize,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Load User Settings Error: $e');
      debugPrint('❌ StackTrace: $stackTrace');

      // مهم:
      // در حالت کاربر لاگین‌شده به تنظیمات Guest یا کاربر قبلی
      // fallback نمی‌کنیم.
    }
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (!_isAuthenticated) {
      await prefsService.setBool(
        StorageConstants.guestTheme,
        event.isDark,
      );

      emit(
        state.copyWith(
          isDarkMode: event.isDark,
        ),
      );

      return;
    }

    try {
      await apiService.updateTheme(
        event.isDark ? 'Dark' : 'Light',
      );

      emit(
        state.copyWith(
          isDarkMode: event.isDark,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ChangeTheme API Error: $e');

      if (e is DioException) {
        debugPrint('❌ Status Code: ${e.response?.statusCode}');
        debugPrint('❌ Response Data: ${e.response?.data}');
        debugPrint('❌ Request Data: ${e.requestOptions.data}');
        debugPrint('❌ Request Headers: ${e.requestOptions.headers}');
      }

      debugPrint('❌ StackTrace: $stackTrace');
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (!_isAuthenticated) {
      await prefsService.setString(
        StorageConstants.guestLanguage,
        event.languageCode,
      );

      emit(
        state.copyWith(
          languageCode: event.languageCode,
        ),
      );

      return;
    }

    try {
      await apiService.updateLanguage(event.languageCode);

      emit(
        state.copyWith(
          languageCode: event.languageCode,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ChangeLanguage API Error: $e');
      debugPrint('❌ StackTrace: $stackTrace');
    }
  }

  Future<void> _onChangeFontSize(
    ChangeFontSizeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    if (!_isAuthenticated) {
      await prefsService.setInt(
        StorageConstants.guestFontSize,
        event.fontSize.toInt(),
      );

      emit(
        state.copyWith(
          fontSize: event.fontSize,
        ),
      );

      return;
    }

    try {
      await apiService.updateFontSize(event.fontSize);

      emit(
        state.copyWith(
          fontSize: event.fontSize,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ChangeFontSize API Error: $e');
      debugPrint('❌ StackTrace: $stackTrace');
    }
  }
}