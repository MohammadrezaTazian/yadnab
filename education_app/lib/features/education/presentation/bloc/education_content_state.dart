import 'package:equatable/equatable.dart';
import '../../domain/entities/education_content.dart';

abstract class EducationContentState extends Equatable {
  const EducationContentState();
  
  @override
  List<Object> get props => [];
}

class EducationContentInitial extends EducationContentState {}

class EducationContentLoading extends EducationContentState {}

class EducationContentLoaded extends EducationContentState {
  final List<EducationContent> contents;

  const EducationContentLoaded(this.contents);

  @override
  List<Object> get props => [contents];
}

class EducationContentError extends EducationContentState {
  final String message;

  const EducationContentError(this.message);

  @override
  List<Object> get props => [message];
}
