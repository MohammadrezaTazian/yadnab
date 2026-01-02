import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? grade;
  final String? profilePicture;

  const User({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.grade,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [id, phoneNumber, firstName, lastName, email, grade, profilePicture];
}
