import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/core/constants/storage_constants.dart';
import 'package:education_app/core/services/api_service.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:education_app/features/settings/presentation/bloc/settings_state.dart';
import 'package:education_app/shared/storage/shared_preferences_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferencesService prefsService;
  final ApiService apiService;

  SettingsBloc({
    required this.prefsService,
    required this.apiService,
  }) : super(const SettingsState()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<ChangeFontSizeEvent>(_onChangeFontSize);
  }

  Future<void> _onLoadSettings(LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    try {
      // Try to load from backend first
      final settings = await apiService.getSettings();
      
      // Save to local storage
      await prefsService.setBool(StorageConstants.theme, settings.theme == 'Dark');
      await prefsService.setString(StorageConstants.language, settings.language);
      await prefsService.setInt(StorageConstants.fontSize, settings.fontSize.toInt());
      
      emit(state.copyWith(
        isDarkMode: settings.theme == 'Dark',
        languageCode: settings.language,
        fontSize: settings.fontSize,
      ));
    } catch (e) {
      // Fallback to local storage if backend fails
      final isDark = prefsService.getBool(StorageConstants.theme) ?? false;
      final lang = prefsService.getString(StorageConstants.language) ?? 'fa';
      final fontSize = prefsService.getInt(StorageConstants.fontSize)?.toDouble() ?? 14.0;

      emit(state.copyWith(
        isDarkMode: isDark,
        languageCode: lang,
        fontSize: fontSize,
      ));
    }
  }

  Future<void> _onChangeTheme(ChangeThemeEvent event, Emitter<SettingsState> emit) async {
    try {
      // Save to backend
      await apiService.updateTheme(event.isDark ? 'Dark' : 'Light');
      
      // Save to local storage
      await prefsService.setBool(StorageConstants.theme, event.isDark);
      
      emit(state.copyWith(isDarkMode: event.isDark));
    } catch (e) {
      // If backend fails, still save locally
      await prefsService.setBool(StorageConstants.theme, event.isDark);
      emit(state.copyWith(isDarkMode: event.isDark));
    }
  }

  Future<void> _onChangeLanguage(ChangeLanguageEvent event, Emitter<SettingsState> emit) async {
    try {
      // Save to backend
      await apiService.updateLanguage(event.languageCode);
      
      // Save to local storage
      await prefsService.setString(StorageConstants.language, event.languageCode);
      
      emit(state.copyWith(languageCode: event.languageCode));
    } catch (e) {
      // If backend fails, still save locally
      await prefsService.setString(StorageConstants.language, event.languageCode);
      emit(state.copyWith(languageCode: event.languageCode));
    }
  }

  Future<void> _onChangeFontSize(ChangeFontSizeEvent event, Emitter<SettingsState> emit) async {
    try {
      // Save to backend
      await apiService.updateFontSize(event.fontSize);
      
      // Save to local storage
      await prefsService.setInt(StorageConstants.fontSize, event.fontSize.toInt());
      
      emit(state.copyWith(fontSize: event.fontSize));
    } catch (e) {
      // If backend fails, still save locally
      await prefsService.setInt(StorageConstants.fontSize, event.fontSize.toInt());
      emit(state.copyWith(fontSize: event.fontSize));
    }
  }
}
