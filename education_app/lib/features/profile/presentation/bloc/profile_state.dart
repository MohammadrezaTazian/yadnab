import 'package:equatable/equatable.dart';
import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/profile/domain/entities/educational_level.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final List<EducationalLevel> educationalLevels;

  const ProfileLoaded({
    required this.user,
    required this.educationalLevels,
  });

  @override
  List<Object?> get props => [user, educationalLevels];
}

class ProfileUpdating extends ProfileState {
  final User user;
  final List<EducationalLevel> educationalLevels;

  const ProfileUpdating({
    required this.user,
    required this.educationalLevels,
  });

  @override
  List<Object?> get props => [user, educationalLevels];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdated extends ProfileState {
  final User user;
  final List<EducationalLevel> educationalLevels;

  const ProfileUpdated({
    required this.user,
    required this.educationalLevels,
  });

  @override
  List<Object?> get props => [user, educationalLevels];
}

