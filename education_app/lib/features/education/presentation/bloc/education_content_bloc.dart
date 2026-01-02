import 'package:flutter_bloc/flutter_bloc.dart';
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
  }

  Future<void> _onGetEducationContentsByTopic(
    GetEducationContentsByTopicEvent event,
    Emitter<EducationContentState> emit,
  ) async {
    emit(EducationContentLoading());
    final result = await getEducationContentsByTopic(event.topicItemId);
    result.fold(
      (failure) => emit(EducationContentError(failure.message)),
      (contents) => emit(EducationContentLoaded(contents)),
    );
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
          emit(EducationContentLoaded(updatedContents));
        },
      );
    }
  }
}

