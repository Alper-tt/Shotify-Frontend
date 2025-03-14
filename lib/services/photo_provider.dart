import 'package:flutter/material.dart';
import 'dart:io';

class PhotoProvider extends ChangeNotifier {
  File? _selectedImage;
  List<Map<String, String>> _songs = [];
  String? _firebasePhotoUrl;


  File? get selectedImage => _selectedImage;
  List<Map<String, String>> get songs => _songs;
  String? get firebasePhotoUrl => _firebasePhotoUrl;


  void setImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void setSongs(List<Map<String, String>> newSongs) {
    _songs = newSongs;
    notifyListeners();
  }

  void setFirebasePhotoUrl(String url) {
    _firebasePhotoUrl = url;
    notifyListeners();
  }
}
