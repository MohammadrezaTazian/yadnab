import 'package:equatable/equatable.dart';
import '../../domain/entities/question.dart';

abstract class QuestionState extends Equatable {
  const QuestionState();
  
  @override
  List<Object> get props => [];
}

class QuestionInitial extends QuestionState {}

class QuestionLoading extends QuestionState {}

class QuestionLoaded extends QuestionState {
  final List<Question> questions;

  const QuestionLoaded(this.questions);

  @override
  List<Object> get props => [questions];
}

class QuestionError extends QuestionState {
  final String message;

  const QuestionError(this.message);

  @override
  List<Object> get props => [message];
}
