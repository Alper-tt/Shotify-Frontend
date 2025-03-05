String normalizeString(String input) {
  return input.toLowerCase().replaceAll(' ', '_');
}

String getSongAssetPath(String artist, String songTitle) {
  final normalizedArtist = normalizeString(artist);
  final normalizedSong = normalizeString(songTitle);
  return 'songs/${normalizedArtist}_${normalizedSong}.mp3';
}
