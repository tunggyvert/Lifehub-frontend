import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_service.dart';

class SearchFilterService {
  final String targetURL = '${ApiService.baseURL}/search';

  Future<Map<String, dynamic>> matchSearch(String query) async {
    final response = await http.get(Uri.parse('$targetURL?lookingat=$query'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded as Map<String, dynamic>;
    } else {
      throw Exception("There's error, Probably missing data.");
    }
  }
}
