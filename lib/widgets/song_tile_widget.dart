import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/photo_preview_screen.dart';
import '../services/audio_player_service.dart';
import '../services/photo_provider.dart';
import '../utils/song_utils.dart';
import 'artist_photo_widget.dart';

class SongTileWidget extends StatefulWidget {
  final String artist;
  final String title;
  final AudioPlayerService audioPlayerService;
  final VoidCallback? onTileTap;

  const SongTileWidget({
    super.key,
    required this.artist,
    required this.title,
    required this.audioPlayerService,
    this.onTileTap,
  });

  @override
  _SongTileWidgetState createState() => _SongTileWidgetState();
}

class _SongTileWidgetState extends State<SongTileWidget> {
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late final String mySongKey;
  StreamSubscription<String?>? _globalSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  @override
  void initState() {
    super.initState();
    mySongKey = normalizeSongName(widget.artist, widget.title);
    _globalSubscription = widget.audioPlayerService.currentSongStream.listen((currentKey) {
      if (currentKey != mySongKey && isPlaying) {
        setState(() {
          isPlaying = false;
          _position = Duration.zero;
          _duration = Duration.zero;
        });
      }
      if (currentKey == mySongKey && !isPlaying) {
        setState(() {
          isPlaying = true;
        });
      }
    });
    _durationSubscription = widget.audioPlayerService.audioPlayer.onDurationChanged.listen((dur) {
      setState(() {
        _duration = dur;
      });
    });
    _positionSubscription = widget.audioPlayerService.audioPlayer.onPositionChanged.listen((pos) {
      setState(() {
        _position = pos;
      });
    });
  }

  @override
  void dispose() {
    _globalSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    super.dispose();
  }

  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  Future<void> togglePlay() async {
    if (isPlaying) {
      await widget.audioPlayerService.stopSong();
    } else {
      await widget.audioPlayerService.playSong(widget.artist, widget.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
        if (photoProvider.selectedImage != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoPreviewScreen(
                artist: widget.artist,
                title: widget.title,
                audioPlayerService: widget.audioPlayerService,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No photo selected.")),
          );
        }
      },
      leading: ArtistPhotoWidget(artistName: widget.artist),
      title: Text(widget.title),
      subtitle: Text(widget.artist),
      trailing: GestureDetector(
        onTap: () async {
          await togglePlay();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: ProgressIndicatorTheme(
                data: ProgressIndicatorThemeData(
                ),
                child: CircularProgressIndicator(
                  value: isPlaying ? progress : 1,
                  strokeWidth: 2.5,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
            Icon(isPlaying ? Icons.stop : Icons.play_arrow),
          ],
        ),
      ),
    );
  }
}
