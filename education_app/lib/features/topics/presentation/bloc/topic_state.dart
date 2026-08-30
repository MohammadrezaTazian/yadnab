import 'package:equatable/equatable.dart';
import 'package:education_app/features/topics/domain/entities/topic.dart';

abstract class TopicState extends Equatable {
  const TopicState();

  @override
  List<Object?> get props => [];
}

class TopicInitial extends TopicState {}

class TopicLoading extends TopicState {}

class TopicLoaded extends TopicState {
  final List<Topic> topics;
  final List<Topic> filteredTopics;
  final String searchQuery;
  final bool isSearching;
  /// مجموعه‌ای از id‌های topic‌هایی که باید هنگام جستجو باز باشند
  final Set<int> expandedTopicIds;

  const TopicLoaded(
    this.topics, {
    this.filteredTopics = const [],
    this.searchQuery = '',
    this.isSearching = false,
    this.expandedTopicIds = const {},
  });

  TopicLoaded copyWith({
    List<Topic>? topics,
    List<Topic>? filteredTopics,
    String? searchQuery,
    bool? isSearching,
    Set<int>? expandedTopicIds,
  }) {
    return TopicLoaded(
      topics ?? this.topics,
      filteredTopics: filteredTopics ?? this.filteredTopics,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      expandedTopicIds: expandedTopicIds ?? this.expandedTopicIds,
    );
  }

  @override
  List<Object?> get props => [
        topics,
        filteredTopics,
        searchQuery,
        isSearching,
        expandedTopicIds,
      ];
}

class TopicError extends TopicState {
  final String message;

  const TopicError(this.message);

  @override
  List<Object?> get props => [message];
}
