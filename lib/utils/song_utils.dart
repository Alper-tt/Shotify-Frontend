String normalizeSongName(String artist, String title) {
  final Map<String, String> turkishMap = {
    'ı': 'i',
    'ğ': 'g',
    'ü': 'u',
    'ş': 's',
    'ö': 'o',
    'ç': 'c',
    'İ': 'i',
    'Ğ': 'g',
    'Ü': 'u',
    'Ş': 's',
    'Ö': 'o',
    'Ç': 'c',
  };

  String normalize(String input) {
    String result = input;
    turkishMap.forEach((turkish, english) {
      result = result.replaceAll(turkish, english);
    });
    return result;
  }

  final normalizedArtist = normalize(artist.trim().toLowerCase()).replaceAll(' ', '_');
  final normalizedTitle = normalize(title.trim().toLowerCase()).replaceAll(' ', '_');
  return "${normalizedArtist}_${normalizedTitle}.mp3";
}

String getSongUrlFromArtistAndTitle(String artist, String title) {
  final fileName = normalizeSongName(artist, title);
  return "preview_musics/$fileName";
}