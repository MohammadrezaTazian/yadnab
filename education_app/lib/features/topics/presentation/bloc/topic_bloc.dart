import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/topics/domain/usecases/get_topics.dart';
import 'package:education_app/features/topics/presentation/bloc/topic_event.dart';
import 'package:education_app/features/topics/presentation/bloc/topic_state.dart';

class TopicBloc extends Bloc<TopicEvent, TopicState> {
  final GetTopics getTopics;

  TopicBloc({required this.getTopics}) : super(TopicInitial()) {
    on<LoadTopics>(_onLoadTopics);
  }

  Future<void> _onLoadTopics(
    LoadTopics event,
    Emitter<TopicState> emit,
  ) async {
    emit(TopicLoading());
    try {
      final topics = await getTopics(event.packageId);
      emit(TopicLoaded(topics));
    } catch (e) {
      emit(TopicError(e.toString()));
    }
  }
}
