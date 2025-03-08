import 'package:flutter/material.dart';
import 'package:shotify_frontend/services/video_service.dart';
import 'package:shotify_frontend/widgets/artist_photo_widget.dart';
import '../services/audio_player_service.dart';
import '../services/photo_provider.dart';
import 'package:provider/provider.dart';

class PhotoPreviewScreen extends StatefulWidget {
  final String artist;
  final String title;
  final AudioPlayerService audioPlayerService;

  const PhotoPreviewScreen({
    super.key,
    required this.artist,
    required this.title,
    required this.audioPlayerService,
  });

  @override
  _PhotoPreviewScreenState createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.audioPlayerService.playSong(widget.artist, widget.title);
    });
  }

  @override
  void dispose() {
    widget.audioPlayerService.stopSong();
    super.dispose();
  }

  VideoService videoService = VideoService();

  @override
  Widget build(BuildContext context) {
    var photoProvider = Provider.of<PhotoProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: photoProvider.selectedImage != null
                  ? Image.file(photoProvider.selectedImage!, fit: BoxFit.contain)
                  : const CircularProgressIndicator(),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ArtistPhotoWidget(artistName:widget.artist),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.artist,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/disc-spinning.gif',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        String imagePath = photoProvider.selectedImage!.path;
                        String videoPath = await videoService.createVideo(imagePath, widget.artist, widget.title);
                        videoService.saveVideoToGallery(videoPath);
                      },
                      child: const Text("Save to Phone"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        String imagePath = photoProvider.selectedImage!.path;
                        String videoPath = await videoService.createVideo(imagePath, widget.artist, widget.title);
                        videoService.shareVideo(videoPath);
                      },
                      child: const Text("Share"),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
