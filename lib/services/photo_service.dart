import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PhotoService {
  final String baseUrl = "http://10.0.2.2:8080";

  Future<int?> uploadPhoto(File imageFile) async {
    var uri = Uri.parse("$baseUrl/photos");

    var request = http.MultipartRequest("POST", uri)
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path))
      ..fields["requestDTO"] = jsonEncode({"userId": 1});

    var response = await request.send();
    if (response.statusCode == 201) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      return jsonResponse["photoId"];
    } else {
      print("Fotoğraf yükleme başarısız: ${response.statusCode}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> analyzePhoto(int photoId) async {
    var uri = Uri.parse("$baseUrl/integration/analyze-photo");
    var response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"photoId": photoId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Fotoğraf analizi başarısız: ${response.statusCode}");
      return null;
    }
  }
}
