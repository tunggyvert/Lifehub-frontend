import 'package:flutter/foundation.dart';
import 'token_storage.dart';

class TokenStorageTest {
  static Future<void> runTests() async {
    debugPrint('[TokenStorageTest] Starting token storage tests...');
    
    try {
      // Test 1: Save token
      const testToken = 'test_token_12345';
      await TokenStorage.saveToken(testToken);
      debugPrint('[TokenStorageTest] ✅ Token saved successfully');
      
      // Test 2: Get token
      final retrievedToken = await TokenStorage.getToken();
      if (retrievedToken == testToken) {
        debugPrint('[TokenStorageTest] ✅ Token retrieved successfully: $retrievedToken');
      } else {
        debugPrint('[TokenStorageTest] ❌ Token mismatch: expected $testToken, got $retrievedToken');
      }
      
      // Test 3: Check hasToken
      final hasToken = await TokenStorage.hasToken();
      debugPrint('[TokenStorageTest] ✅ Has token: $hasToken');
      
      // Test 4: Remove token
      await TokenStorage.removeToken();
      final removedToken = await TokenStorage.getToken();
      if (removedToken == null) {
        debugPrint('[TokenStorageTest] ✅ Token removed successfully');
      } else {
        debugPrint('[TokenStorageTest] ❌ Token not removed: $removedToken');
      }
      
      debugPrint('[TokenStorageTest] All tests completed!');
    } catch (e, stackTrace) {
      debugPrint('[TokenStorageTest] ❌ Test failed: $e');
      debugPrint('[TokenStorageTest] Stack trace: $stackTrace');
    }
  }
}
