import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/question.dart';
import '../../domain/usecases/get_questions_by_topic.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final GetQuestionsByTopic getQuestionsByTopic;

  QuestionBloc({required this.getQuestionsByTopic}) : super(QuestionInitial()) {
    on<GetQuestionsEvent>(_onGetQuestions);
    on<SearchQuestionsEvent>(_onSearchQuestions);
    on<ClearQuestionsSearchEvent>(_onClearQuestionsSearch);
    on<ToggleQuestionsSearchVisibilityEvent>(_onToggleQuestionsSearchVisibility);
  }

  Future<void> _onGetQuestions(
    GetQuestionsEvent event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionLoading());
    final result = await getQuestionsByTopic(event.topicId);
    result.fold(
      (failure) => emit(QuestionError(_mapFailureToMessage(failure))),
      (questions) => emit(QuestionLoaded(questions, filteredQuestions: questions)),
    );
  }

  void _onSearchQuestions(
    SearchQuestionsEvent event,
    Emitter<QuestionState> emit,
  ) {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final query = event.query.trim().toLowerCase();
      final filtered = _filterQuestions(currentState.questions, query);
      emit(currentState.copyWith(
        filteredQuestions: filtered,
        searchQuery: query,
      ));
    }
  }

  void _onClearQuestionsSearch(
    ClearQuestionsSearchEvent event,
    Emitter<QuestionState> emit,
  ) {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      emit(currentState.copyWith(
        filteredQuestions: currentState.questions,
        searchQuery: '',
      ));
    }
  }

  void _onToggleQuestionsSearchVisibility(
    ToggleQuestionsSearchVisibilityEvent event,
    Emitter<QuestionState> emit,
  ) {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final nextIsSearching = !currentState.isSearching;
      emit(currentState.copyWith(
        isSearching: nextIsSearching,
        filteredQuestions: nextIsSearching ? currentState.filteredQuestions : currentState.questions,
        searchQuery: nextIsSearching ? currentState.searchQuery : '',
      ));
    }
  }

  List<Question> _filterQuestions(List<Question> questions, String query) {
    if (query.isEmpty) return questions;
    return questions.where((q) {
      return q.questionText.toLowerCase().contains(query);
    }).toList();
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

