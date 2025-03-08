import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import '../utils/song_utils.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  final AudioPlayer audioPlayer = AudioPlayer();

  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  String? _currentSongKey;
  final StreamController<String?> _currentSongController = StreamController.broadcast();

  Stream<String?> get currentSongStream => _currentSongController.stream;
  String? get currentSongKey => _currentSongKey;

  Future<void> playSong(String artist, String songTitle) async {
    try {
      final newKey = normalizeSongName(artist, songTitle);
      if (_currentSongKey != null && _currentSongKey != newKey) {
        await stopSong();
      }
      final songUrl = await getSongUrl(artist, songTitle);
      await audioPlayer.stop();
      _currentSongKey = newKey;
      _currentSongController.add(_currentSongKey);
      await audioPlayer.play(UrlSource(songUrl));
    } catch (e) {
      print("Şarkı çalınırken hata oluştu: $e");
    }
  }

  Future<void> stopSong() async {
    await audioPlayer.stop();
    _currentSongKey = null;
    _currentSongController.add(_currentSongKey);
  }

  Future<void> pauseSong() async {
    await audioPlayer.pause();
  }

  Future<void> resumeSong() async {
    await audioPlayer.resume();
  }

  void dispose() {
    audioPlayer.dispose();
    _currentSongController.close();
  }

  Future<String> getSongUrl(String artist, String title) async {
    String url = getSongUrlFromArtistAndTitle(artist, title);
    Reference ref = FirebaseStorage.instance.ref().child(url);
    return await ref.getDownloadURL();
  }

  Future<String> downloadAudioFile(String artist, String title) async {
    final audioUrl = await AudioPlayerService().getSongUrl(artist, title);
    final response = await http.get(Uri.parse(audioUrl));

    if (response.statusCode == 200) {
      final Directory tempDir = await getTemporaryDirectory();
      final fileName = normalizeSongName(artist, title);
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print("Audio downloaded to: $filePath");
      return filePath;
    } else {
      throw Exception('Failed to download audio file. Status: ${response.statusCode}');
    }
  }
}

