import 'package:education_app/core/config/config_service.dart';

class UrlHelper {
  static String resolve(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http')) {
      return path;
    }
    // Ensure path starts with / if not present (optional, but good for safety)
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '${ConfigService().imageBaseUrl}$cleanPath';
  }
}
