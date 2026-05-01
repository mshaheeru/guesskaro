import 'package:flutter/material.dart';

import '../common/supabase_phrase_image.dart';

/// Photo-only card with optional rounding and placeholder.
class PhotoCard extends StatelessWidget {
  const PhotoCard({
    super.key,
    required this.imageUrl,
    this.aspectRatio = 4 / 5,
    this.radius = 16,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double aspectRatio;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: const Color(0xFFF2F2F2),
          child: SupabasePhraseImage(
            imageUrl: imageUrl,
            fit: fit,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
