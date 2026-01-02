import 'package:equatable/equatable.dart';

abstract class QuestionEvent extends Equatable {
  const QuestionEvent();

  @override
  List<Object> get props => [];
}

class GetQuestionsEvent extends QuestionEvent {
  final int topicItemId;

  const GetQuestionsEvent(this.topicItemId);

  @override
  List<Object> get props => [topicItemId];
}
