import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/audio_player_service.dart';
import '../services/photo_provider.dart';
import 'artist_photo_widget.dart';

class RecommendedSongList extends StatelessWidget {
  const RecommendedSongList({
    required this.photoProvider,
    required this.audioPlayerService,
  });

  final PhotoProvider photoProvider;
  final AudioPlayerService audioPlayerService;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: photoProvider.songs.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: ArtistPhotoWidget(artistName: photoProvider.songs[index]["songArtist"] ?? "Unknown Artist"),
          title: Text(photoProvider.songs[index]["songTitle"] ?? "Unknown Song"),
          subtitle: Text(photoProvider.songs[index]["songArtist"] ?? "Unknown Artist"),
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              final artist = photoProvider.songs[index]["songArtist"] ?? "Unknown Artist";
              final title = photoProvider.songs[index]["songTitle"] ?? "Unknown Song";
              await audioPlayerService.playSong(artist,title);
            },
          ),
        );
      },
    );
  }
}
