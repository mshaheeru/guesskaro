import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/phrase_image_disk_cache.dart';

/// Shared phrase image: disk-backed network cache, shimmer placeholder, graceful error.
class SupabasePhraseImage extends StatelessWidget {
  const SupabasePhraseImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _errorBox();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl.trim(),
      fit: fit,
      alignment: alignment,
      cacheManager: PhraseImageDiskCache.manager,
      placeholder: (BuildContext _, String __) =>
          ColoredBox(
            color: AppColors.bgCard,
            child: Shimmer.fromColors(
              baseColor: AppColors.bgCard,
              highlightColor: AppColors.bgElevated,
              child: Container(color: AppColors.bgCard),
            ),
          ),
      errorWidget: (BuildContext _, String __, Object ___) => _errorBox(),
    );
  }

  Widget _errorBox() {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      child: const Center(
        child: Text('🖼', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}
