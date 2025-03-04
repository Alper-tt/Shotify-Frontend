import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shotify_frontend/services/photo_provider.dart';
import 'dart:io';
import '../services/photo_service.dart';
import '../widgets/artist_photo_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> _songs = [];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      Provider.of<PhotoProvider>(context, listen: false).setImage(File(pickedFile.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 160,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadAndAnalyzePhoto() async {
    var photoProvider = Provider.of<PhotoProvider>(context, listen: false);

    if (photoProvider.selectedImage != null) {
      PhotoService photoService = PhotoService();
      int? photoId = await photoService.uploadPhoto(photoProvider.selectedImage!);

      if (photoId != null) {
        print("Fotoğraf başarıyla yüklendi. Photo ID: $photoId");

        var analysisResponse = await photoService.analyzePhoto(photoId);
        if (analysisResponse != null) {
          photoProvider.setSongs(
            (analysisResponse["songs"] as List).map((song) => {
              "songTitle": song["songTitle"] as String,
              "songArtist": song["songArtist"] as String
            }).toList(),
          );
          print("Analiz sonucu: ${photoProvider.songs}");
        }
      }
    } else {
      print("Lütfen bir fotoğraf seçin!");
    }
  }


  @override
  Widget build(BuildContext context) {
    var photoProvider = Provider.of<PhotoProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Shotify"), centerTitle: true,),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          opacity: 0.1,
                          image: AssetImage("assets/images/home_screenbg.png"),
                        ),
                      ),
                    ),
                    Container(
                      width: 225,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: photoProvider.selectedImage != null
                              ? FileImage(photoProvider.selectedImage!) as ImageProvider
                              : const AssetImage("assets/images/storyph.png"),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    if (photoProvider.selectedImage == null)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.upload_file,
                            color: Colors.white,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Upload a Photo",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: ElevatedButton(
                onPressed: _uploadAndAnalyzePhoto,
                child: const Text("Upload & Analyze Photo"),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: photoProvider.songs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: ArtistPhotoWidget(artistName: photoProvider.songs[index]["songArtist"] ?? "Unknown Artist"),
                  title: Text(photoProvider.songs[index]["songTitle"] ?? "Unknown Song"),
                  subtitle: Text(photoProvider.songs[index]["songArtist"] ?? "Unknown Artist"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
