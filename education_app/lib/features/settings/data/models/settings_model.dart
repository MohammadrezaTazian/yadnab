class SettingsModel {
  final String theme;
  final String language;
  final double fontSize;

  const SettingsModel({
    required this.theme,
    required this.language,
    required this.fontSize,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      theme: json['theme'] ?? 'Light',
      language: json['language'] ?? 'fa',
      fontSize: (json['fontSize'] ?? 14.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'fontSize': fontSize,
    };
  }

  SettingsModel copyWith({
    String? theme,
    String? language,
    double? fontSize,
  }) {
    return SettingsModel(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}
