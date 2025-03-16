import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendAuthService {
  final String _baseUrl = "http://10.0.2.2:8080";

  Future<int?> registerUser(String firebaseUid, String email) async {
    final url = Uri.parse("$_baseUrl/users");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"firebaseUid": firebaseUid, "email": email}),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> decoded = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return decoded["userId"];
    } else {
      print("Kullanıcı kaydı başarısız: ${response.body}");
      return null;
    }
  }

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  Future<void> syncUserWithBackend(User user) async {
    print("userid "+ user.uid);
    final userId = await registerUser(user.uid, user.email ?? "");
    if (userId != null) {
      await saveUserId(userId);
      print(userId);
    } else {
      print("Backend ile senkronizasyon başarısız.");
    }
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

}
