import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetComments implements UseCase<List<Comment>, GetCommentsParams> {
  final CommentRepository repository;

  GetComments(this.repository);

  @override
  Future<Either<Failure, List<Comment>>> call(GetCommentsParams params) async {
    return await repository.getComments(params.targetId, params.targetType);
  }
}

class GetCommentsParams extends Equatable {
  final int targetId;
  final int targetType;

  const GetCommentsParams({required this.targetId, required this.targetType});

  @override
  List<Object?> get props => [targetId, targetType];
}
