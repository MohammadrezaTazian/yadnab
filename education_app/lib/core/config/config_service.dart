import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  String _apiBaseUrl = '';

  String get apiBaseUrl => _apiBaseUrl;

  Future<void> load() async {
    try {
      if (kIsWeb) {
        // On Web, try to fetch config.json from the server root
        try {
          // Prevent caching with a timestamp parameter
          final response = await Dio().get(
            'config.json?v=${DateTime.now().millisecondsSinceEpoch}',
            options: Options(responseType: ResponseType.plain),
          );
          final jsonConfig = json.decode(response.data);
          _apiBaseUrl = jsonConfig['apiBaseUrl'];
          debugPrint('Loaded config from web: $_apiBaseUrl');
          return;
        } catch (e) {
          debugPrint('Failed to load external config.json on web, falling back to assets: $e');
        }
      }

      // Fallback or Mobile: Load from assets
      final jsonString = await rootBundle.loadString('assets/config.json');
      final jsonConfig = json.decode(jsonString);
      _apiBaseUrl = jsonConfig['apiBaseUrl'];
      debugPrint('Loaded config from assets: $_apiBaseUrl');

    } catch (e) {
      debugPrint('Error loading config: $e');
      // Hard fallback if everything fails
      _apiBaseUrl = 'http://localhost:5100/api';
    }
  }
}
