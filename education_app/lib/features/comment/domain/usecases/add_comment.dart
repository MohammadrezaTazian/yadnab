import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class AddComment implements UseCase<Comment, AddCommentParams> {
  final CommentRepository repository;

  AddComment(this.repository);

  @override
  Future<Either<Failure, Comment>> call(AddCommentParams params) async {
    return await repository.addComment(
      targetId: params.targetId,
      targetType: params.targetType,
      content: params.content,
      parentCommentId: params.parentCommentId,
    );
  }
}

class AddCommentParams extends Equatable {
  final int targetId;
  final int targetType;
  final String content;
  final int? parentCommentId;

  const AddCommentParams({
    required this.targetId,
    required this.targetType,
    required this.content,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [targetId, targetType, content, parentCommentId];
}
