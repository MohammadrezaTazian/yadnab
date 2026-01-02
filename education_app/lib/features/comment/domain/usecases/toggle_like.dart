import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/comment_repository.dart';

class ToggleLike implements UseCase<bool, ToggleLikeParams> {
  final CommentRepository repository;

  ToggleLike(this.repository);

  @override
  Future<Either<Failure, bool>> call(ToggleLikeParams params) async {
    return await repository.toggleLike(params.targetId, params.targetType);
  }
}

class ToggleLikeParams extends Equatable {
  final int targetId;
  final int targetType;

  const ToggleLikeParams({required this.targetId, required this.targetType});

  @override
  List<Object?> get props => [targetId, targetType];
}
