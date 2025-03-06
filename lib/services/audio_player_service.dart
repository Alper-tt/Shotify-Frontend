import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../utils/song_utils.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal();

  Future<void> playSong(String artist, String songTitle) async {
    try {
      final songUrl = await getSongUrl(artist, songTitle);
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(songUrl));
    } catch (e) {
      print("Şarkı çalınırken hata oluştu: $e");
    }
  }

  Future<void> stopSong() async {
    await _audioPlayer.stop();
  }

  Future<void> pauseSong() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeSong() async {
    await _audioPlayer.resume();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

Future<String> getSongUrl(String artist, String title) async {
  String url = getSongUrlFromArtistAndTitle(artist, title);
  Reference ref = FirebaseStorage.instance.ref().child(url);
  return await ref.getDownloadURL();
}