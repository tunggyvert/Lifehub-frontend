import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrlFromDefine = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseURL {
    if (_baseUrlFromDefine.isNotEmpty) return _baseUrlFromDefine;

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    return 'http://127.0.0.1:3000';
  }

  final Duration timeout;

  ApiService({this.timeout = const Duration(seconds: 15)});

  void _debugLogRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
  }) {
    if (!kDebugMode) return;
    final auth = headers == null ? null : headers['Authorization'];
    final authPreview = auth == null
        ? 'none'
        : auth.length <= 18
        ? auth
        : '${auth.substring(0, 18)}...';
    debugPrint('[ApiService] $method $url auth=$authPreview');
  }

  void _debugLogResponse(String method, Uri url, http.Response response) {
    if (!kDebugMode) return;
    debugPrint('[ApiService] $method $url -> ${response.statusCode}');
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseURL$endpoint');
    try {
      final headers = {'Content-Type': 'application/json'};
      _debugLogRequest('POST', url, headers: headers);
      return await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(timeout);
    } on TimeoutException catch (e) {
      throw ApiException('Request timeout', url: url, cause: e);
    } catch (e) {
      throw ApiException('Request failed', url: url, cause: e);
    }
  }

  Future<http.Response> get(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseURL$endpoint');
    final headers = <String, String>{};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      _debugLogRequest('GET', url, headers: headers);
      final response = await http.get(url, headers: headers).timeout(timeout);
      _debugLogResponse('GET', url, response);
      return response;
    } on TimeoutException catch (e) {
      throw ApiException('Request timeout', url: url, cause: e);
    } catch (e) {
      throw ApiException('Request failed', url: url, cause: e);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final Uri? url;
  final Object? cause;

  ApiException(this.message, {this.url, this.cause});

  @override
  String toString() {
    final urlPart = url == null ? '' : ' url=$url';
    final causePart = cause == null ? '' : ' cause=$cause';
    return 'ApiException($message$urlPart$causePart)';
  }
}
