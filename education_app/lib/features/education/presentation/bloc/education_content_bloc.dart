import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/education_content.dart';
import 'education_content_event.dart';
import 'education_content_state.dart';
import '../../domain/usecases/get_education_contents_by_topic.dart';
import 'package:education_app/features/comment/domain/usecases/toggle_like.dart';

class EducationContentBloc extends Bloc<EducationContentEvent, EducationContentState> {
  final GetEducationContentsByTopic getEducationContentsByTopic;
  final ToggleLike toggleLike;

  EducationContentBloc({
    required this.getEducationContentsByTopic,
    required this.toggleLike,
  }) : super(EducationContentInitial()) {
    on<GetEducationContentsByTopicEvent>(_onGetEducationContentsByTopic);
    on<ToggleLikeEvent>(_onToggleLike);
    on<SearchEducationContentEvent>(_onSearchEducationContent);
    on<ClearEducationContentSearchEvent>(_onClearEducationContentSearch);
    on<ToggleEducationContentSearchVisibilityEvent>(_onToggleEducationContentSearchVisibility);
  }

  Future<void> _onGetEducationContentsByTopic(
    GetEducationContentsByTopicEvent event,
    Emitter<EducationContentState> emit,
  ) async {
    emit(EducationContentLoading());
    final result = await getEducationContentsByTopic(event.topicId);
    result.fold(
      (failure) => emit(EducationContentError(failure.message)),
      (contents) => emit(EducationContentLoaded(contents, filteredContents: contents)),
    );
  }

  void _onSearchEducationContent(
    SearchEducationContentEvent event,
    Emitter<EducationContentState> emit,
  ) {
    if (state is EducationContentLoaded) {
      final currentState = state as EducationContentLoaded;
      final query = event.query.trim().toLowerCase();
      final filtered = _filterContents(currentState.contents, query);
      emit(currentState.copyWith(
        filteredContents: filtered,
        searchQuery: query,
      ));
    }
  }

  void _onClearEducationContentSearch(
    ClearEducationContentSearchEvent event,
    Emitter<EducationContentState> emit,
  ) {
    if (state is EducationContentLoaded) {
      final currentState = state as EducationContentLoaded;
      emit(currentState.copyWith(
        filteredContents: currentState.contents,
        searchQuery: '',
      ));
    }
  }

  void _onToggleEducationContentSearchVisibility(
    ToggleEducationContentSearchVisibilityEvent event,
    Emitter<EducationContentState> emit,
  ) {
    if (state is EducationContentLoaded) {
      final currentState = state as EducationContentLoaded;
      final nextIsSearching = !currentState.isSearching;
      emit(currentState.copyWith(
        isSearching: nextIsSearching,
        filteredContents: nextIsSearching ? currentState.filteredContents : currentState.contents,
        searchQuery: nextIsSearching ? currentState.searchQuery : '',
      ));
    }
  }

  List<EducationContent> _filterContents(List<EducationContent> contents, String query) {
    if (query.isEmpty) return contents;
    return contents.where((content) {
      final titleMatch = content.title.toLowerCase().contains(query);
      final teacherMatch = content.teacherName?.toLowerCase().contains(query) ?? false;
      return titleMatch || teacherMatch;
    }).toList();
  }

  Future<void> _onToggleLike(
    ToggleLikeEvent event,
    Emitter<EducationContentState> emit,
  ) async {
    final currentState = state;
    if (currentState is EducationContentLoaded) {
      final result = await toggleLike(ToggleLikeParams(
        targetId: event.contentId,
        targetType: 3, // EducationContent
      ));
      
      result.fold(
        (failure) {
          // Silently fail or show error
        },
        (isLiked) {
          // Update the specific content's like status
          final updatedContents = currentState.contents.map((content) {
            if (content.id == event.contentId) {
              return content.copyWith(isLiked: isLiked);
            }
            return content;
          }).toList();

          final updatedFiltered = currentState.filteredContents.map((content) {
            if (content.id == event.contentId) {
              return content.copyWith(isLiked: isLiked);
            }
            return content;
          }).toList();

          emit(currentState.copyWith(
            contents: updatedContents,
            filteredContents: updatedFiltered,
          ));
        },
      );
    }
  }
}


