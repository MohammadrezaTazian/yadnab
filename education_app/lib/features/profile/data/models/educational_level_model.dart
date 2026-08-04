import 'package:education_app/features/profile/domain/entities/educational_level.dart';

class EducationalLevelModel extends EducationalLevel {
  const EducationalLevelModel({
    required super.id,
    required super.name,
  });

  factory EducationalLevelModel.fromJson(Map<String, dynamic> json) {
    return EducationalLevelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
