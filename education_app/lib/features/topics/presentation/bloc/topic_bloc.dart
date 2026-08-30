import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/topics/domain/entities/topic.dart';
import 'package:education_app/features/topics/domain/usecases/get_topics.dart';
import 'package:education_app/features/topics/presentation/bloc/topic_event.dart';
import 'package:education_app/features/topics/presentation/bloc/topic_state.dart';

class TopicBloc extends Bloc<TopicEvent, TopicState> {
  final GetTopics getTopics;

  TopicBloc({required this.getTopics}) : super(TopicInitial()) {
    on<LoadTopics>(_onLoadTopics);
    on<SearchTopics>(_onSearchTopics);
    on<ClearSearch>(_onClearSearch);
    on<ToggleSearchVisibility>(_onToggleSearchVisibility);
  }

  Future<void> _onLoadTopics(
    LoadTopics event,
    Emitter<TopicState> emit,
  ) async {
    emit(TopicLoading());
    try {
      final topics = await getTopics(event.packageId);
      emit(TopicLoaded(topics, filteredTopics: topics));
    } catch (e) {
      emit(TopicError(e.toString()));
    }
  }

  void _onSearchTopics(
    SearchTopics event,
    Emitter<TopicState> emit,
  ) {
    if (state is TopicLoaded) {
      final currentState = state as TopicLoaded;
      final query = event.query.trim().toLowerCase();
      final filtered = _filterTopics(currentState.topics, query);
      // شناسه‌ی تمام والدینی که باید هنگام جستجو باز باشند
      final expanded = query.isNotEmpty
          ? _getParentIdsToExpand(filtered)
          : <int>{};
      emit(currentState.copyWith(
        filteredTopics: filtered,
        searchQuery: query,
        expandedTopicIds: expanded,
      ));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<TopicState> emit,
  ) {
    if (state is TopicLoaded) {
      final currentState = state as TopicLoaded;
      emit(currentState.copyWith(
        filteredTopics: currentState.topics,
        searchQuery: '',
        expandedTopicIds: {},
      ));
    }
  }

  void _onToggleSearchVisibility(
    ToggleSearchVisibility event,
    Emitter<TopicState> emit,
  ) {
    if (state is TopicLoaded) {
      final currentState = state as TopicLoaded;
      final nextIsSearching = !currentState.isSearching;
      emit(currentState.copyWith(
        isSearching: nextIsSearching,
        filteredTopics: nextIsSearching ? currentState.filteredTopics : currentState.topics,
        searchQuery: nextIsSearching ? currentState.searchQuery : '',
        expandedTopicIds: nextIsSearching ? currentState.expandedTopicIds : {},
      ));
    }
  }

  /// بازگشتی: تمام id‌های topic‌هایی که فرزند دارند را از لیست فیلترشده جمع‌آوری می‌کند.
  /// این مجموعه به UI می‌گوید کدام ExpansionTile‌ها باید باز باشند.
  Set<int> _getParentIdsToExpand(List<Topic> filteredTopics) {
    final ids = <int>{};
    for (final topic in filteredTopics) {
      if (topic.children.isNotEmpty) {
        ids.add(topic.id);
        // پیمایش بازگشتی برای سطوح عمیق‌تر
        ids.addAll(_getParentIdsToExpand(topic.children));
      }
    }
    return ids;
  }

  List<Topic> _filterTopics(List<Topic> topics, String query) {
    if (query.isEmpty) return topics;

    final List<Topic> result = [];
    for (final topic in topics) {
      final titleMatches = topic.title.toLowerCase().contains(query);

      if (topic.children.isNotEmpty) {
        if (titleMatches) {
          result.add(topic);
        } else {
          final filteredChildren = _filterTopics(topic.children, query);
          if (filteredChildren.isNotEmpty) {
            result.add(Topic(
              id: topic.id,
              parentId: topic.parentId,
              title: topic.title,
              imageUrl: topic.imageUrl,
              children: filteredChildren,
            ));
          }
        }
      } else {
        if (titleMatches) {
          result.add(topic);
        }
      }
    }
    return result;
  }
}


