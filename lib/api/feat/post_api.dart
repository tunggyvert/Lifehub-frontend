import 'dart:convert';
import '../../models/post_model.dart';
import '../api_service.dart';
import '../../core/storage/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io';

class PostApi {
  final ApiService _apiService = ApiService();

  Future<List<Post>> getPosts() async {
    final token = await TokenStorage.getToken();

    final response = await _apiService.get('/api/posts/', token: token);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List data = decoded is List ? decoded : decoded['data'];

      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Post> getPostById(int postId) async {
    final token = await TokenStorage.getToken();

    final response = await _apiService.get('/api/posts/$postId', token: token);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Handle both wrapped and unwrapped responses
      if (decoded is Map && decoded.containsKey('data')) {
        return Post.fromJson(decoded['data']);
      }
      return Post.fromJson(decoded);
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<List<Post>> getPostsByUserId(int userId) async {
    final token = await TokenStorage.getToken();
    print('PostApi: Getting posts for user $userId');

    final response = await _apiService.get(
      '/api/posts/user/$userId',
      token: token,
    );
    print('PostApi: Response status: ${response.statusCode}');
    print('PostApi: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print('PostApi: Decoded response: $decoded');

      final List data = decoded is List ? decoded : decoded['data'] ?? [];
      print('PostApi: Found ${data.length} posts');
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      print('PostApi: Failed to load posts - Status: ${response.statusCode}');
      throw Exception('Failed to load user posts');
    }
  }

  Future<String> uploadImage(File imageFile) async {
    debugPrint('[PostApi] Starting image upload');

    final token = await TokenStorage.getToken();
    if (token == null) {
      debugPrint('[PostApi] No token found - user not logged in');
      throw Exception("User not logged in.");
    }

    // Create multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseURL}/api/upload'),
    );

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add image file
    final imageStream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();
    final multipartFile = http.MultipartFile(
      'image',
      imageStream,
      length,
      filename: imageFile.path.split('/').last,
    );

    request.files.add(multipartFile);

    debugPrint('[PostApi] Sending upload request...');

    try {
      final response = await request.send();

      debugPrint('[PostApi] Upload response status: ${response.statusCode}');

      // Read response body
      final responseBody = await response.stream.bytesToString();
      debugPrint('[PostApi] Upload response body: $responseBody');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseBody);
        if (decoded['success'] == true && decoded['imageUrl'] != null) {
          debugPrint(
            '[PostApi] Image uploaded successfully: ${decoded['imageUrl']}',
          );
          return decoded['imageUrl'];
        } else {
          throw Exception(decoded['message'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[PostApi] Upload error: $e');
      rethrow;
    }
  }

  Future<void> createPost({
    required String caption,
    required String image_url,
  }) async {
    debugPrint('[PostApi] Creating post with caption: $caption');
    debugPrint('[PostApi] Image URL: $image_url');

    final token = await TokenStorage.getToken();

    if (token == null) {
      debugPrint('[PostApi] No token found - user not logged in');
      throw Exception("User not logged in.");
    }

    debugPrint(
      '[PostApi] Token found, making API call to: ${ApiService.baseURL}/api/posts/',
    );

    final response = await http.post(
      Uri.parse('${ApiService.baseURL}/api/posts/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'caption': caption, 'image_url': image_url}),
    );

    debugPrint('[PostApi] Response status: ${response.statusCode}');
    debugPrint('[PostApi] Response body: ${response.body}');

    if (response.statusCode != 201) {
      debugPrint(
        '[PostApi] Create post failed with status: ${response.statusCode}',
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      // Try to parse error message from backend
      String errorMessage = "Create post failed";
      try {
        final decoded = jsonDecode(response.body);
        if (decoded['message'] != null) {
          errorMessage = decoded['message'];
        }
      } catch (e) {
        // If parsing fails, use default message
      }

      throw Exception(errorMessage);
    }

    debugPrint('[PostApi] Post created successfully');
  }

  Future<bool> toggleLike(int postId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception("User not logged in.");

    final response = await http.post(
      Uri.parse('${ApiService.baseURL}/api/posts/$postId/like'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['liked'] ??
          false; // คืนค่ากลับมาว่าตอนนี้สถามะคือ Liked (true) หรือ Unliked (false)
    } else {
      throw Exception("Toggle like failed");
    }
  }

  Future<void> addComment(int postId, String content) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception("User not logged in.");

    final response = await http.post(
      Uri.parse('${ApiService.baseURL}/api/posts/$postId/comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to add comment");
    }
  }

  Future<List<dynamic>> getComments(int postId) async {
    final token = await TokenStorage.getToken();
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse('${ApiService.baseURL}/api/posts/$postId/comments'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    } else {
      throw Exception("Failed to load comments");
    }
  }

  // เพิ่ม method สำหรับ refresh ข้อมูลโพสต์
  Future<Post> refreshPost(int postId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception("User not logged in.");

    final response = await _apiService.get('/api/posts/$postId', token: token);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return Post.fromJson(decoded['data']);
    } else {
      throw Exception("Failed to refresh post data");
    }
  }

  // เพิ่ม method สำหรับ refresh ความเห็น
  Future<List<dynamic>> refreshComments(int postId) async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception("User not logged in.");

    final response = await http.get(
      Uri.parse('${ApiService.baseURL}/api/posts/$postId/comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    } else {
      throw Exception("Failed to refresh comments");
    }
  }
}
