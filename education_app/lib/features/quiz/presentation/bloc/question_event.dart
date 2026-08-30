import 'package:equatable/equatable.dart';

abstract class QuestionEvent extends Equatable {
  const QuestionEvent();

  @override
  List<Object> get props => [];
}

class GetQuestionsEvent extends QuestionEvent {
  final int topicId;

  const GetQuestionsEvent(this.topicId);

  @override
  List<Object> get props => [topicId];
}

class SearchQuestionsEvent extends QuestionEvent {
  final String query;

  const SearchQuestionsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearQuestionsSearchEvent extends QuestionEvent {}

class ToggleQuestionsSearchVisibilityEvent extends QuestionEvent {}

