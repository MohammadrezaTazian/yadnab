import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final ApiService apiService;

  CommentRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<Comment>>> getComments(int targetId, int targetType) async {
    try {
      final jsonList = await apiService.getComments(targetId, targetType);
      final comments = jsonList.map((e) => CommentModel.fromJson(e)).toList();
      return Right(comments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment({
    required int targetId,
    required int targetType,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final data = {
        'targetId': targetId,
        'targetType': targetType,
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      };
      final jsonResponse = await apiService.addComment(data);
      return Right(CommentModel.fromJson(jsonResponse));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleLike(int targetId, int targetType) async {
    try {
      final result = await apiService.toggleLike(targetId, targetType);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(int commentId) async {
    try {
      await apiService.deleteComment(commentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
