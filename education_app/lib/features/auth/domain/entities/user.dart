import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final int? educationalLevelId;
  final String? educationalLevelName;
  final String? profilePicture;

  const User({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.educationalLevelId,
    this.educationalLevelName,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        firstName,
        lastName,
        email,
        educationalLevelId,
        educationalLevelName,
        profilePicture,
      ];
}

