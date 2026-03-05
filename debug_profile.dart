import 'lib/core/storage/token_storage.dart';
import 'lib/api/feat/post_api.dart';
import 'lib/models/post_model.dart';

void main() async {
  // First check if we have a token
  final token = await TokenStorage.getToken();
  print('Token exists: ${token != null}');
  print('Token value: ${token?.substring(0, 20)}...');
  
  if (token == null) {
    print('❌ No token found - user not logged in');
    return;
  }
  
  // Test the API call
  try {
    print('🔄 Making API call to /api/posts/user/1...');
    final posts = await PostApi().getPostsByUserId(1);
    print('✅ Success! Got ${posts.length} posts');
    
    for (final post in posts.take(3)) {
      print('📝 Post ${post.id}: ${post.caption ?? 'No caption'}');
    }
    
  } catch (e) {
    print('❌ API Error: $e');
  }
}
