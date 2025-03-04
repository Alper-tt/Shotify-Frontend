String normalizeArtistName(String artistName) {
  return artistName.toLowerCase().replaceAll(' ', '_');
}

String getArtistAssetPath(String artistName) {
  final normalized = normalizeArtistName(artistName);
  return "assets/artist_images/$normalized.jpg";
}
