import 'package:equatable/equatable.dart';
import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/profile/domain/entities/grade.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final List<Grade> grades;

  const ProfileLoaded({
    required this.user,
    required this.grades,
  });

  @override
  List<Object?> get props => [user, grades];
}

class ProfileUpdating extends ProfileState {
  final User user;
  final List<Grade> grades;

  const ProfileUpdating({
    required this.user,
    required this.grades,
  });

  @override
  List<Object?> get props => [user, grades];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdated extends ProfileState {
  final User user;
  final List<Grade> grades;

  const ProfileUpdated({
    required this.user,
    required this.grades,
  });

  @override
  List<Object?> get props => [user, grades];
}
