import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shotify_frontend/services/audio_player_service.dart';

class VideoService {
  Future<String?> createVideo(String photoUrl, String artist, String title) async {
    print("Photo path: $photoUrl");

    String audioPath = await AudioPlayerService().getSongUrl(artist, title);
    print(photoUrl);

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8080/video/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"photoPath": photoUrl, "audioUrl": audioPath}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(utf8.decode(response.bodyBytes));
      return decoded["videoUrl"];
    } else {
      print("Video URL'si alınamadı: ${response.body}");
      return null;
    }
  }

  Future<String> downloadVideo(String videoUrl) async {
    final response = await http.get(Uri.parse(videoUrl));
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      throw Exception('Video indirme başarısız: ${response.statusCode}');
    }
  }

  Future<void> saveVideoToGallery(String videoFilePath) async {
    await FlutterImageGallerySaver.saveFile(videoFilePath);
  }

  Future<void> shareVideo(String videoFilePath) async {
    await Share.shareXFiles([XFile(videoFilePath)], text: 'Check out this cool video!');
  }

  Future<void> processVideo(String videoUrl, {required String action}) async {
    try {
      String videoFilePath = await downloadVideo(videoUrl);
      if (action == "save") {
        await saveVideoToGallery(videoFilePath);
      } else if (action == "share") {
        await shareVideo(videoFilePath);
      }
      if (await File(videoFilePath).exists()) {
        await File(videoFilePath).delete();
      }
    } catch (e) {
      throw Exception('Video işlemi sırasında hata oluştu: $e');
    }
  }
}
