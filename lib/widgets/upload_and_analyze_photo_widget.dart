import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/photo_service.dart';
import '../services/photo_provider.dart';

class UploadAnalyzeButton extends StatefulWidget {
  const UploadAnalyzeButton({Key? key}) : super(key: key);

  @override
  _UploadAnalyzeButtonState createState() => _UploadAnalyzeButtonState();
}

class _UploadAnalyzeButtonState extends State<UploadAnalyzeButton> {
  bool _isLoading = false;

  Future<void> _uploadAndAnalyzePhoto() async {
    var photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    if (photoProvider.selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir fotoğraf seçin!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    PhotoService photoService = PhotoService();
    final response = await photoService.uploadAndAnalyzePhoto(photoProvider.selectedImage!, context);

    if (response != null) {
      photoProvider.setSongs(
        (response["songs"] as List).map((song) => {
          "songTitle": song["songTitle"] as String,
          "songArtist": song["songArtist"] as String,
        }).toList(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fotoğraf yükleme/analiz sırasında hata oluştu!")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _uploadAndAnalyzePhoto,
          child: _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text("Upload & Analyze Photo"),
        ),
      ),
    );
  }
}
