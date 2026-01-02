import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment.dart';

abstract class CommentRepository {
  Future<Either<Failure, List<Comment>>> getComments(int targetId, int targetType);
  Future<Either<Failure, Comment>> addComment({
    required int targetId,
    required int targetType,
    required String content,
    int? parentCommentId,
  });
  Future<Either<Failure, bool>> toggleLike(int targetId, int targetType);
  Future<Either<Failure, void>> deleteComment(int commentId);
}
