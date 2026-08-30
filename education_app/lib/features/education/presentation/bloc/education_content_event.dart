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

class SearchEducationContentEvent extends EducationContentEvent {
  final String query;

  const SearchEducationContentEvent(this.query);

  @override
  List<Object> get props => [query];
}

class ClearEducationContentSearchEvent extends EducationContentEvent {}

class ToggleEducationContentSearchVisibilityEvent extends EducationContentEvent {}


