import 'dart:convert';

import 'package:http/http.dart' as http;

class RecommendationService {
  Future<Map<String, dynamic>> fetchRecommendations(int photoId) async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/recommendations/photo/$photoId"),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Failed to load recommendations");
    }
  }
}
