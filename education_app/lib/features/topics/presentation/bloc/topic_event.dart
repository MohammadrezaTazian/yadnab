import 'package:equatable/equatable.dart';

abstract class TopicEvent extends Equatable {
  const TopicEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopics extends TopicEvent {
  final int packageId;

  const LoadTopics(this.packageId);

  @override
  List<Object?> get props => [packageId];
}
