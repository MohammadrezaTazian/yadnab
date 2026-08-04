import 'package:equatable/equatable.dart';

class EducationalLevel extends Equatable {
  final int id;
  final String name;

  const EducationalLevel({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
