import 'package:equatable/equatable.dart';

abstract class EducationContentEvent extends Equatable {
  const EducationContentEvent();

  @override
  List<Object> get props => [];
}

class GetEducationContentsByTopicEvent extends EducationContentEvent {
  final int topicId;

  const GetEducationContentsByTopicEvent(this.topicId);

  @override
  List<Object> get props => [topicId];
}

class ToggleLikeEvent extends EducationContentEvent {
  final int contentId;

  const ToggleLikeEvent(this.contentId);

  @override
  List<Object> get props => [contentId];
}

