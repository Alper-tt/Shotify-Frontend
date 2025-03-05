import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal();

  Future<void> playSong(String artist, String songTitle) async {
    try {
      final songUrl = await getSongUrlFromArtistAndTitle(artist, songTitle);
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

String normalizeSongName(String artist, String title) {
  return "${artist.trim().toLowerCase().replaceAll(' ', '_')}_${title.toLowerCase().trim().replaceAll(' ', '_')}.mp3";
}

Future<String> getSongUrl(String fileName) async {
  Reference ref = FirebaseStorage.instance.ref().child("preview_musics/$fileName");
  return await ref.getDownloadURL();
}

Future<String> getSongUrlFromArtistAndTitle(String artist, String title) async {
  final fileName = normalizeSongName(artist, title);
  return await getSongUrl(fileName);
}
