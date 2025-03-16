import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shotify_frontend/services/backend_auth_service.dart';
import 'package:shotify_frontend/services/photo_provider.dart';


class Photo {
  final int photoId;
  final String photoUrl;

  Photo({required this.photoId, required this.photoUrl});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json["photoId"],
      photoUrl: json["url"],
    );
  }
}

class PhotoService {
  final String uploadUrl = "http://10.0.2.2:8080";
  final analyzeUrl = Uri.parse(
    'http://10.0.2.2:8080/integration/analyze-photo',
  );
  int? photoId;
  String? photoUrl;

  Future<Map<String, dynamic>?> uploadAndAnalyzePhoto(File imageFile, BuildContext context) async {
    var uri = Uri.parse("$uploadUrl/photos");

    var request =
    http.MultipartRequest("POST", uri)
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path))
      ..fields["requestDTO"] = jsonEncode({"userId": 1});

    var response = await request.send();
    if (response.statusCode == 201) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      photoId = jsonResponse["photoId"];
      photoUrl = jsonResponse["url"];
      Provider.of<PhotoProvider>(context,listen: false).setFirebasePhotoUrl(photoUrl!);
    } else {
      print("Fotoğraf yükleme başarısız: ${response.statusCode}");
      return null;
    }

    final analyzeResponse = await http.post(
      analyzeUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"photoId": photoId}),
    );

    if (analyzeResponse.statusCode == 200) {
      final decodedResponse = json.decode(
        utf8.decode(analyzeResponse.bodyBytes),
      );
      return decodedResponse;
    } else {
      print("Fotoğraf analizi başarısız: ${analyzeResponse.body}");
      return null;
    }
  }

  Future<List<Photo>> fetchPhotos() async {
    int? userId = await BackendAuthService().getUserId();

    if (userId == null) {
      throw Exception("User ID bulunamadı!");
    }

    final response = await http.get(Uri.parse("http://10.0.2.2:8080/users/$userId/photos"));
    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Photo> photos = jsonData.map((photoJson) => Photo.fromJson(photoJson)).toList();
      return photos;
    } else {
      throw Exception("Failed to load photos");
    }
  }

}