import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:education_app/features/course_topics/domain/usecases/get_course_topics.dart';
import 'package:education_app/features/course_topics/presentation/bloc/course_topic_event.dart';
import 'package:education_app/features/course_topics/presentation/bloc/course_topic_state.dart';

class CourseTopicBloc extends Bloc<CourseTopicEvent, CourseTopicState> {
  final GetCourseTopics getCourseTopics;

  CourseTopicBloc({required this.getCourseTopics}) : super(CourseTopicInitial()) {
    on<LoadCourseTopics>(_onLoadCourseTopics);
  }

  Future<void> _onLoadCourseTopics(
    LoadCourseTopics event,
    Emitter<CourseTopicState> emit,
  ) async {
    emit(CourseTopicLoading());
    try {
      final courseTopic = await getCourseTopics(event.category);
      emit(CourseTopicLoaded(courseTopic));
    } catch (e) {
      emit(CourseTopicError(e.toString()));
    }
  }
}
