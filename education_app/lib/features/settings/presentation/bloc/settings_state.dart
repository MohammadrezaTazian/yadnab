import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;
  final String languageCode;
  final double fontSize;

  const SettingsState({
    this.isDarkMode = false,
    this.languageCode = 'fa',
    this.fontSize = 14.0,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? languageCode,
    double? fontSize,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, languageCode, fontSize];
}
