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

  const TopicLoaded(this.topics);

  @override
  List<Object?> get props => [topics];
}

class TopicError extends TopicState {
  final String message;

  const TopicError(this.message);

  @override
  List<Object?> get props => [message];
}
