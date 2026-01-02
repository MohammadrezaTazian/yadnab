import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class LoadGradesEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? grade;

  const UpdateProfileEvent({
    this.firstName,
    this.lastName,
    this.email,
    this.grade,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, grade];
}

class UpdateProfilePictureEvent extends ProfileEvent {
  final String base64Image;

  const UpdateProfilePictureEvent(this.base64Image);

  @override
  List<Object> get props => [base64Image];
}
