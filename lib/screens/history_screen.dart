import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../widgets/artist_photo_widget.dart';

class Photo {
  final int photoId;
  final String url;

  Photo({required this.photoId, required this.url});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json["photoId"],
      url: "http://10.0.2.2:8080${json['url']}",
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<Photo>> fetchPhotos() async {
    final response =
    await http.get(Uri.parse("http://10.0.2.2:8080/users/1/photos"));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<Photo> photos =
      jsonData.map((photoJson) => Photo.fromJson(photoJson)).toList();
      return photos;
    } else {
      throw Exception("Failed to load photos");
    }
  }

  Future<Map<String, dynamic>> fetchRecommendations(int photoId) async {
    final response = await http.get(
        Uri.parse("http://10.0.2.2:8080/recommendations/photo/$photoId"));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Failed to load recommendations");
    }
  }

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
              future: fetchRecommendations(photo.photoId),
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
                            image: NetworkImage(photo.url),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<Photo>>(
          future: fetchPhotos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error loading photos"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No photos found"));
            }
            var photos = snapshot.data!;
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
                        image: NetworkImage(photo.url),
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
