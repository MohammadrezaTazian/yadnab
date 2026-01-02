import '../../domain/entities/difficulty_level.dart';

class DifficultyLevelModel extends DifficultyLevel {
  const DifficultyLevelModel({
    required super.id,
    required super.name,
    required super.nameEn,
  });

  factory DifficultyLevelModel.fromJson(Map<String, dynamic> json) {
    return DifficultyLevelModel(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
    };
  }
}
