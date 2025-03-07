import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/photo_provider.dart';

class PhotoUploadWidget extends StatefulWidget {
  const PhotoUploadWidget({super.key});

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (!mounted) return;
    if (pickedFile != null) {
      Provider.of<PhotoProvider>(context, listen: false)
          .setImage(File(pickedFile.path));
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

  @override
  Widget build(BuildContext context) {
    var photoProvider = Provider.of<PhotoProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: GestureDetector(
          onTap: _showImageSourceDialog,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
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
                        ? FileImage(photoProvider.selectedImage!)
                        : const AssetImage("assets/images/storyph.png"),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              if (photoProvider.selectedImage == null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.upload_file,
                      color: Colors.white,
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
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
    );
  }
}
