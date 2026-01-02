import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:education_app/core/constants/api_constants.dart';
import 'package:education_app/features/home/data/models/product_model.dart';
import 'package:education_app/features/settings/data/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  ApiService({
    required this.dio,
    required this.sharedPreferences,
  });

  Options _getOptions() {
    final token = sharedPreferences.getString('access_token');
    return Options(
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // Products API
  Future<List<ProductModel>> getProducts({String? category}) async {
    final url = category != null && category.isNotEmpty
        ? '${ApiConstants.baseUrl}${ApiConstants.products}?category=$category'
        : '${ApiConstants.baseUrl}${ApiConstants.products}';

    final response = await dio.get(url, options: _getOptions());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Settings API
  Future<SettingsModel> getSettings() async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}${ApiConstants.settings}',
      options: _getOptions(),
    );

    if (response.statusCode == 200) {
      return SettingsModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load settings');
    }
  }

  Future<void> updateTheme(String theme) async {
    final response = await dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.theme}',
      data: theme,
      options: _getOptions(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update theme');
    }
  }

  Future<void> updateLanguage(String language) async {
    final response = await dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.language}',
      data: language,
      options: _getOptions(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update language');
    }
  }

  Future<void> updateFontSize(double fontSize) async {
    final response = await dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.fontSize}',
      data: fontSize,
      options: _getOptions(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update font size');
    }
  }

  // Profile Picture API
  Future<Map<String, dynamic>> updateProfilePicture(String base64Image) async {
    developer.log('Uploading profile picture to: ${ApiConstants.baseUrl}/User/profile-picture');
    developer.log('Base64 image length: ${base64Image.length}');
    
    final response = await dio.post(
      '${ApiConstants.baseUrl}/User/profile-picture',
      data: {'base64Image': base64Image},
      options: _getOptions(),
    );

    developer.log('Profile picture upload response: ${response.statusCode}');
    developer.log('Response body: ${response.data}');

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to update profile picture: ${response.statusCode} - ${response.data}');
    }
  }

  // Course Topics API
  Future<Map<String, dynamic>> getCourseTopics(String category) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}/CourseTopics/$category',
      options: _getOptions(),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load course topics');
    }
  }

  // Questions API
  Future<dynamic> getQuestionsByTopic(int topicItemId) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}/Questions/topic/$topicItemId',
      options: _getOptions(),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load questions');
    }
  }

  // Education Contents API
  Future<dynamic> getEducationContentsByTopic(int topicItemId) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}/EducationContents/topic/$topicItemId',
      options: _getOptions(),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load education contents');
    }
  }

  // Comments & Likes API
  Future<List<dynamic>> getComments(int targetId, int targetType) async {
    final response = await dio.get(
      '${ApiConstants.baseUrl}/Comments/$targetType/$targetId',
      options: _getOptions(),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<dynamic> addComment(Map<String, dynamic> data) async {
    final response = await dio.post(
      '${ApiConstants.baseUrl}/Comments',
      data: data,
      options: _getOptions(),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to add comment: ${response.statusCode}');
    }
  }

  Future<bool> toggleLike(int targetId, int targetType) async {
    final response = await dio.post(
      '${ApiConstants.baseUrl}/Likes/toggle',
      data: {
        'targetId': targetId,
        'targetType': targetType,
      },
      options: _getOptions(),
    );

    if (response.statusCode == 200) {
      return response.data['isLiked'] ?? false;
    } else {
      throw Exception('Failed to toggle like');
    }
  }

  Future<void> deleteComment(int commentId) async {
    final response = await dio.delete(
      '${ApiConstants.baseUrl}/Comments/$commentId',
      options: _getOptions(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment: ${response.statusCode}');
    }
  }
}
