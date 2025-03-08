import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';
import '../services/photo_provider.dart';
import 'song_tile_widget.dart';

class RecommendedSongList extends StatelessWidget {
  const RecommendedSongList({
    Key? key,
    required this.photoProvider,
    required this.audioPlayerService,
  }) : super(key: key);

  final PhotoProvider photoProvider;
  final AudioPlayerService audioPlayerService;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: photoProvider.songs.length,
      itemBuilder: (context, index) {
        final song = photoProvider.songs[index];
        return SongTileWidget(
          artist: song["songArtist"] ?? "Unknown Artist",
          title: song["songTitle"] ?? "Unknown Song",
          audioPlayerService: audioPlayerService,
        );
      },
    );
  }
}
