import 'dart:async';
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
  VideoService videoService = VideoService();

  bool _isSaving = false;
  bool _isSharing = false;
  double _saveProgress = 0.0;
  double _shareProgress = 0.0;
  Timer? _saveProgressTimer;
  Timer? _shareProgressTimer;

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
    _saveProgressTimer?.cancel();
    _shareProgressTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSavingProcess() async {
    setState(() {
      _isSaving = true;
      _saveProgress = 0.0;
    });

    int totalDurationInSeconds = 70;
    int elapsedSeconds = 0;
    _saveProgressTimer =
        Timer.periodic(const Duration(seconds: 1), (Timer timer) {
          elapsedSeconds++;
          setState(() {
            _saveProgress = elapsedSeconds / totalDurationInSeconds;
          });
          if (elapsedSeconds >= totalDurationInSeconds) {
            timer.cancel();
          }
        });

    var photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    String? photoUrl = photoProvider.firebasePhotoUrl;
    if (photoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fotoğraf bilgisi bulunamadı!")),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }
    String? videoUrl = await videoService.createVideo(photoUrl, widget.artist, widget.title);
    videoService.processVideo(videoUrl!, action: "save");

    _saveProgressTimer?.cancel();
    setState(() {
      _saveProgress = 1.0;
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Video başarıyla galeriye kaydedildi!")),
    );
  }

  Future<void> _startSharingProcess() async {
    setState(() {
      _isSharing = true;
      _shareProgress = 0.0;
    });

    int totalDurationInSeconds = 70;
    int elapsedSeconds = 0;
    _shareProgressTimer =
        Timer.periodic(const Duration(seconds: 1), (Timer timer) {
          elapsedSeconds++;
          setState(() {
            _shareProgress = elapsedSeconds / totalDurationInSeconds;
          });
          if (elapsedSeconds >= totalDurationInSeconds) {
            timer.cancel();
          }
        });

    var photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    String? photoUrl = photoProvider.firebasePhotoUrl;
    if (photoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fotoğraf bilgisi bulunamadı!")),
      );
      setState(() {
        _isSharing = false;
      });
      return;
    }
    String? videoUrl = await videoService.createVideo(photoUrl, widget.artist, widget.title);
    videoService.processVideo(videoUrl!, action: "share");

    _shareProgressTimer?.cancel();
    setState(() {
      _shareProgress = 1.0;
      _isSharing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Video paylaşım için hazır!")),
    );
  }

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
                  ArtistPhotoWidget(artistName: widget.artist),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.artist,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
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
              padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _isSaving
                        ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Saving...",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _saveProgress,
                          backgroundColor: Colors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blue),
                        ),
                      ],
                    )
                        : ElevatedButton(
                      onPressed: _startSavingProcess,
                      child: const Text("Save to Phone"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _isSharing
                        ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Sharing...",
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _shareProgress,
                          backgroundColor: Colors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green),
                        ),
                      ],
                    )
                        : ElevatedButton(
                      onPressed: _startSharingProcess,
                      child: const Text("Share"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
