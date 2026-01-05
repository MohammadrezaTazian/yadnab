import 'package:dartz/dartz.dart';
import 'package:education_app/core/error/failures.dart';
import 'package:education_app/features/upload/data/datasources/upload_data_source.dart';
import 'package:education_app/features/upload/data/models/entity_search_result.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadRepository {
  Future<Either<Failure, List<EntitySearchResult>>> searchEntities(int entityTypeId, String? searchText);
  Future<Either<Failure, void>> uploadImage(int entityTypeId, int entityId, XFile imageFile, String? altText);
}

class UploadRepositoryImpl implements UploadRepository {
  final UploadDataSource dataSource;

  UploadRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<EntitySearchResult>>> searchEntities(int entityTypeId, String? searchText) async {
    try {
      final result = await dataSource.searchEntities(entityTypeId, searchText);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadImage(int entityTypeId, int entityId, XFile imageFile, String? altText) async {
    try {
      await dataSource.uploadImage(entityTypeId, entityId, imageFile, altText);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
