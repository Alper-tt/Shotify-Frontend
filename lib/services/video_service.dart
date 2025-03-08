import 'dart:io';
import 'package:flutter_image_gallery_saver/flutter_image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shotify_frontend/services/audio_player_service.dart';


class VideoService{


  Future<String> createVideo(String imagePath, String artist, String title) async {
    String audioPath = await AudioPlayerService().downloadAudioFile(artist, title);

    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath = '${tempDir.path}/output_video.mp4';

    final String command = '-loop 1 -i "$imagePath" -i "$audioPath" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "$outputPath"';

    //await FFmpegKit.execute(command);

    return outputPath;
  }

  void saveVideoToGallery(String videoPath) async {
    await FlutterImageGallerySaver.saveFile(videoPath);
    print("Video galeride kaydedildi: $videoPath");
  }

  void shareVideo(String videoPath) {
    Share.shareXFiles([XFile(videoPath)], text: 'Check out this cool video!');
  }

}