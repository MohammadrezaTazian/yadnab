import 'package:equatable/equatable.dart';

class Grade extends Equatable {
  final int id;
  final String name;

  const Grade({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
