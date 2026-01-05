import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:education_app/core/config/config_service.dart';
import 'package:education_app/core/constants/api_constants.dart';
import 'package:education_app/core/error/failures.dart';
import 'package:education_app/features/upload/data/models/entity_search_result.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadDataSource {
  Future<List<EntitySearchResult>> searchEntities(int entityTypeId, String? searchText);
  Future<void> uploadImage(int entityTypeId, int entityId, XFile imageFile, String? altText);
}

class UploadDataSourceImpl implements UploadDataSource {
  final Dio client;
  final ConfigService configService;

  UploadDataSourceImpl({required this.client, required this.configService});

  @override
  Future<List<EntitySearchResult>> searchEntities(int entityTypeId, String? searchText) async {
    try {
      final baseUrl = configService.apiBaseUrl;
      final response = await client.get(
        '$baseUrl/ContentManagement/search',
        queryParameters: {
          'entityTypeId': entityTypeId,
          'searchText': searchText,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => EntitySearchResult.fromJson(json)).toList();
      } else {
        throw const ServerFailure('Failed to fetch data');
      }
    } catch (e) {
      throw const ServerFailure('Server Error');
    }
  }

  @override
  Future<void> uploadImage(int entityTypeId, int entityId, XFile imageFile, String? altText) async {
    try {
      final baseUrl = configService.apiBaseUrl;
      
      // Read bytes from XFile
      final bytes = await imageFile.readAsBytes();
      
      final formData = FormData.fromMap({
        'EntityTypeId': entityTypeId,
        'EntityId': entityId,
        'AltText': altText,
        'ImageFile': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name,
        ),
      });

      final response = await client.post(
        '$baseUrl/ContentManagement/upload',
        data: formData,
      );

      if (response.statusCode != 200) {
        throw const ServerFailure('Upload failed');
      }
    } catch (e) {
      throw const ServerFailure('Server Error');
    }
  }
}
