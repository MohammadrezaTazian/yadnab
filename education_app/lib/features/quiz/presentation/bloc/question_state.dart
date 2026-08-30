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
  final List<Question> filteredQuestions;
  final String searchQuery;
  final bool isSearching;

  const QuestionLoaded(
    this.questions, {
    this.filteredQuestions = const [],
    this.searchQuery = '',
    this.isSearching = false,
  });

  QuestionLoaded copyWith({
    List<Question>? questions,
    List<Question>? filteredQuestions,
    String? searchQuery,
    bool? isSearching,
  }) {
    return QuestionLoaded(
      questions ?? this.questions,
      filteredQuestions: filteredQuestions ?? this.filteredQuestions,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object> get props => [questions, filteredQuestions, searchQuery, isSearching];
}

class QuestionError extends QuestionState {
  final String message;

  const QuestionError(this.message);

  @override
  List<Object> get props => [message];
}
