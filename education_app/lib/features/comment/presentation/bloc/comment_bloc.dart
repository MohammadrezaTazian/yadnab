import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/toggle_like.dart';
import '../../domain/repositories/comment_repository.dart';

abstract class CommentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCommentsEvent extends CommentEvent {
  final int targetId;
  final int targetType;

  LoadCommentsEvent({required this.targetId, required this.targetType});

  @override
  List<Object?> get props => [targetId, targetType];
}

class AddCommentEvent extends CommentEvent {
  final int targetId;
  final int targetType;
  final String content;
  final int? parentCommentId;

  AddCommentEvent({
    required this.targetId,
    required this.targetType,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [targetId, targetType, content, parentCommentId];
}

class DeleteCommentEvent extends CommentEvent {
  final int commentId;
  final int targetId;
  final int targetType;

  DeleteCommentEvent({required this.commentId, required this.targetId, required this.targetType});
  
  @override
  List<Object?> get props => [commentId, targetId, targetType];
}

class ToggleLikeEvent extends CommentEvent {
  final int targetId;
  final int targetType;
  final int parentTargetId; // To reload the list
  final int parentTargetType;

  ToggleLikeEvent({
    required this.targetId,
    required this.targetType,
    required this.parentTargetId,
    required this.parentTargetType,
  });

  @override
  List<Object?> get props => [targetId, targetType, parentTargetId, parentTargetType];
}

abstract class CommentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Comment> comments;

  CommentLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentError extends CommentState {
  final String message;

  CommentError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetComments getComments;
  final AddComment addComment;
  final CommentRepository commentRepository;
  final ToggleLike toggleLike;

  CommentBloc({
    required this.getComments,
    required this.addComment,
    required this.commentRepository,
    required this.toggleLike,
  }) : super(CommentInitial()) {
    on<LoadCommentsEvent>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<ToggleLikeEvent>(_onToggleLike);
  }

  Future<void> _onLoadComments(LoadCommentsEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    final result = await getComments(GetCommentsParams(
      targetId: event.targetId,
      targetType: event.targetType,
    ));
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comments) => emit(CommentLoaded(comments)),
    );
  }

  Future<void> _onAddComment(AddCommentEvent event, Emitter<CommentState> emit) async {
    final result = await addComment(AddCommentParams(
      targetId: event.targetId,
      targetType: event.targetType,
      content: event.content,
      parentCommentId: event.parentCommentId,
    ));

    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comment) {
         add(LoadCommentsEvent(targetId: event.targetId, targetType: event.targetType));
      },
    );
  }
  
  Future<void> _onDeleteComment(DeleteCommentEvent event, Emitter<CommentState> emit) async {
     final result = await commentRepository.deleteComment(event.commentId);
     result.fold(
      (failure) => emit(CommentError(failure.message)),
      (_) => add(LoadCommentsEvent(targetId: event.targetId, targetType: event.targetType)),
    );
  }

  Future<void> _onToggleLike(ToggleLikeEvent event, Emitter<CommentState> emit) async {
    final result = await toggleLike(ToggleLikeParams(
      targetId: event.targetId,
      targetType: event.targetType,
    ));
    
    result.fold(
      (failure) => emit(CommentError(failure.message)), // Or ignore/show snackbar
      (isLiked) {
         // Reload comments to update counts/status
         add(LoadCommentsEvent(targetId: event.parentTargetId, targetType: event.parentTargetType));
      },
    );
  }
}
