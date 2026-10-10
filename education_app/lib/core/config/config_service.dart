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
  String get imageBaseUrl => _apiBaseUrl.replaceFirst(RegExp(r'/api$'), '');

  Future<void> load() async {
    try {
      if (kIsWeb) {
        // On Web, load config.json from the server root
        try {
          final response = await Dio().get(
            'config.json?v=${DateTime.now().millisecondsSinceEpoch}',
            options: Options(responseType: ResponseType.plain),
          );
          final jsonConfig = json.decode(response.data);
          _apiBaseUrl = jsonConfig['apiBaseUrl'];
          debugPrint('Loaded config from web: $_apiBaseUrl');
          return;
        } catch (e) {
          debugPrint(
            'Failed to load external config.json on web, falling back to assets: $e',
          );
        }
      }

      // Release build uses production API.
      if (kReleaseMode) {
        // _apiBaseUrl = 'http://87.248.145.101:81/api';
        _apiBaseUrl = 'https://api.yadnab.ir/api';
        debugPrint('Loaded production API: $_apiBaseUrl');
        return;
      }

      // Debug / local development uses assets/config.json.
      final jsonString = await rootBundle.loadString('assets/config.json');
      final jsonConfig = json.decode(jsonString);
      _apiBaseUrl = jsonConfig['apiBaseUrl'];

      // Android Emulator accesses the Windows host through 10.0.2.2.
      if (defaultTargetPlatform == TargetPlatform.android) {
        _apiBaseUrl = _apiBaseUrl.replaceFirst('localhost', '10.0.2.2');
      }

      debugPrint('Loaded config from assets: $_apiBaseUrl');
    } catch (e) {
      debugPrint('Error loading config: $e');

      // Local fallback for development only.
      _apiBaseUrl = 'http://localhost:5100/api';
    }
  }
}
