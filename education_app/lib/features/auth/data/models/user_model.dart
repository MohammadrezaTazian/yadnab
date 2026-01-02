import 'package:education_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  final String accessToken;
  final String refreshToken;

  const UserModel({
    required super.id,
    required super.phoneNumber,
    super.firstName,
    super.lastName,
    super.email,
    super.grade,
    super.profilePicture,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      grade: json['grade'],
      profilePicture: json['profilePicture'],
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'grade': grade,
      'profilePicture': profilePicture,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
