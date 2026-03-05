import 'lib/api/feat/post_api.dart';
import 'lib/core/storage/token_storage.dart';

void main() async {
  // Test the API with a hardcoded token
  // You'll need to replace with a real token from your app
  
  print('Testing posts API...');
  
  try {
    final posts = await PostApi().getPostsByUserId(1);
    print('Posts loaded: ${posts.length}');
    
    for (final post in posts) {
      print('- Post: ${post.id} - ${post.caption}');
    }
    
  } catch (e) {
    print('Error: $e');
  }
}
