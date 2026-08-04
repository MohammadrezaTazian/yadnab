import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class LoadEducationalLevelsEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? email;
  final int? educationalLevelId;

  const UpdateProfileEvent({
    this.firstName,
    this.lastName,
    this.email,
    this.educationalLevelId,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, educationalLevelId];
}

class UpdateProfilePictureEvent extends ProfileEvent {
  final String base64Image;

  const UpdateProfilePictureEvent(this.base64Image);

  @override
  List<Object> get props => [base64Image];
}

