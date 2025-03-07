import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/photo_provider.dart';
import '../services/audio_player_service.dart';
import '../widgets/photo_upload_widget.dart';
import '../widgets/recommended_songs_list_widget.dart';
import '../widgets/upload_and_analyze_photo_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var photoProvider = Provider.of<PhotoProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shotify"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          PhotoUploadWidget(),
          UploadAnalyzeButton(),
          Expanded(
            child: RecommendedSongList(
              photoProvider: photoProvider,
              audioPlayerService: AudioPlayerService(),
            ),
          ),
        ],
      ),
    );
  }
}
