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
