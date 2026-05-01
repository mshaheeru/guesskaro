import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Disk-backed cache shared by phrase-scene prefetch and [CachedNetworkImage] in gameplay.
///
/// Bounds storage so device isn’t flooded; LRU evicts oldest when over limit.
final class PhraseImageDiskCache {
  PhraseImageDiskCache._();

  static final CacheManager manager = CacheManager(
    Config(
      'jhatpatPhrasePhotos',
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 64,
      fileService: HttpFileService(),
    ),
  );
}
