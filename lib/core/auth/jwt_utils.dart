import 'dart:convert';

class JwtUtils {
  static int? userIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      final payload = parts[1];
      final normalized = base64.normalize(payload.replaceAll('-', '+').replaceAll('_', '/'));
      final decoded = utf8.decode(base64.decode(normalized));
      final map = jsonDecode(decoded);
      final id = map is Map ? map['id'] : null;
      if (id is int) return id;
      if (id is num) return id.toInt();
      if (id is String) return int.tryParse(id);
      return null;
    } catch (_) {
      return null;
    }
  }
}
