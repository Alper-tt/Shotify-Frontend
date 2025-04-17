import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shotify_frontend/services/photo_service.dart';
import 'package:shotify_frontend/services/recommendation_service.dart';
import 'package:shotify_frontend/services/audio_player_service.dart';
import '../widgets/artist_photo_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PhotoService _photoService = PhotoService();
  final RecommendationService _recommendationService = RecommendationService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();

  void showRecommendationsBottomSheet(BuildContext context, Photo photo) {
    showModalBottomSheet(
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.3,
          maxChildSize: 1.0,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<Map<String, dynamic>>(
              future: _recommendationService.fetchRecommendations(photo.photoId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error loading recommendations"));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text("No recommendations found"));
                }
                var data = snapshot.data!;
                var songs = data["songs"] as List<dynamic>;

                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(photo.photoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Song Recommendations",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            var song = songs[index];
                            return ListTile(
                              leading: ArtistPhotoWidget(
                                  artistName: song["songArtist"] ??
                                      "Unknown Artist"),
                              title:
                              Text(song["songTitle"] ?? "Unknown Song"),
                              subtitle:
                              Text(song["songArtist"] ?? "Unknown Artist"),
                              trailing: IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () async {
                                  final artist =
                                      song["songArtist"] ?? "Unknown Artist";
                                  final title =
                                      song["songTitle"] ?? "Unknown Song";
                                  await _audioPlayerService.playSong(
                                      artist, title);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() async {
      await _audioPlayerService.stopSong();
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Geçmiş ekranını görüntülemek için lütfen giriş yapın.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text("Giriş Yap"),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<Photo>>(
          future: _photoService.fetchPhotos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading photos"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No photos found"));
            }
            var photos = snapshot.data!;
            photos = photos.reversed.toList();
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 9 / 16,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                var photo = photos[index];
                return GestureDetector(
                  onTap: () => showRecommendationsBottomSheet(context, photo),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(photo.photoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
