import 'package:flutter/material.dart';
import '../utils/artist_utils.dart';

class ArtistPhotoWidget extends StatelessWidget {
  final String artistName;
  final double width;
  final double height;

  const ArtistPhotoWidget({
    Key? key,
    required this.artistName,
    this.width = 45.0,
    this.height = 45.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetPath = getArtistAssetPath(artistName);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(assetPath),
          ),
        ),
      ),
    );
  }
}
