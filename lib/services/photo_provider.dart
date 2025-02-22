import 'package:flutter/material.dart';
import 'dart:io';

class PhotoProvider extends ChangeNotifier {
  File? _selectedImage;
  List<Map<String, String>> _songs = [];

  File? get selectedImage => _selectedImage;
  List<Map<String, String>> get songs => _songs;

  void setImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void setSongs(List<Map<String, String>> newSongs) {
    _songs = newSongs;
    notifyListeners();
  }
}
