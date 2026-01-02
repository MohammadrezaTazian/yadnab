import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_questions_by_topic.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final GetQuestionsByTopic getQuestionsByTopic;

  QuestionBloc({required this.getQuestionsByTopic}) : super(QuestionInitial()) {
    on<GetQuestionsEvent>(_onGetQuestions);
  }

  Future<void> _onGetQuestions(
    GetQuestionsEvent event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionLoading());
    final result = await getQuestionsByTopic(event.topicItemId);
    result.fold(
      (failure) => emit(QuestionError(_mapFailureToMessage(failure))),
      (questions) => emit(QuestionLoaded(questions)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return 'Server Failure';
      case CacheFailure _:
        return 'Cache Failure';
      default:
        return 'Unexpected Error';
    }
  }
}
