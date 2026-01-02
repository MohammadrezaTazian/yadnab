import 'package:equatable/equatable.dart';

class DifficultyLevel extends Equatable {
  final int id;
  final String name;
  final String nameEn;

  const DifficultyLevel({
    required this.id,
    required this.name,
    required this.nameEn,
  });

  @override
  List<Object?> get props => [id, name, nameEn];
}
