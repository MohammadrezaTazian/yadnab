import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class ChangeThemeEvent extends SettingsEvent {
  final bool isDark;

  const ChangeThemeEvent(this.isDark);

  @override
  List<Object?> get props => [isDark];
}

class ChangeLanguageEvent extends SettingsEvent {
  final String languageCode;

  const ChangeLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class ChangeFontSizeEvent extends SettingsEvent {
  final double fontSize;

  const ChangeFontSizeEvent(this.fontSize);

  @override
  List<Object?> get props => [fontSize];
}
