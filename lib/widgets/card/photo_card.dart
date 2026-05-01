import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/services/phrase_image_disk_cache.dart';
import '../common/supabase_phrase_image.dart';
import '../common/waiting_tin_photo_loader.dart';

/// Photo card: fixed aspect, or layout height derived from decoded image pixels (fewer grey bars).
///
/// [onImageReady] runs once per [imageUrl] after the image has been decoded (or on empty URL).
class PhotoCard extends StatefulWidget {
  const PhotoCard({
    super.key,
    required this.imageUrl,
    this.aspectRatio = 4 / 5,
    this.radius = 16,
    this.fit = BoxFit.contain,
    this.snapNaturalAspect = true,
    this.maxImageHeight = 520,
    this.placeholderAspectRatio = 4 / 3,
    this.onImageReady,
  });

  final String imageUrl;
  final double aspectRatio;

  /// When [snapNaturalAspect] is false, layout uses [aspectRatio] and [fit] only.
  final double radius;

  /// Used when snapping: fits box that matches intrinsic ratio (or [cover] when clamped).
  final BoxFit fit;
  final bool snapNaturalAspect;
  final double maxImageHeight;
  final double placeholderAspectRatio;

  /// Fires once when this URL’s bitmap is decoded (or immediately if URL empty).
  final VoidCallback? onImageReady;

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  double? _widthOverHeight;
  ImageStream? _imageStream;
  ImageStreamListener? _listener;
  bool _readyFired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachImageStream());
  }

  @override
  void didUpdateWidget(covariant PhotoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.snapNaturalAspect != widget.snapNaturalAspect) {
      _readyFired = false;
      if (widget.snapNaturalAspect) {
        setState(() => _widthOverHeight = null);
      }
      _detachDecoder();
      WidgetsBinding.instance.addPostFrameCallback((_) => _attachImageStream());
    }
  }

  @override
  void dispose() {
    _detachDecoder();
    super.dispose();
  }

  void _fireReadyOnce() {
    if (_readyFired || !mounted) return;
    _readyFired = true;
    widget.onImageReady?.call();
  }

  void _detachDecoder() {
    if (_listener != null && _imageStream != null) {
      _imageStream!.removeListener(_listener!);
    }
    _listener = null;
    _imageStream = null;
  }

  void _attachImageStream() {
    if (!mounted) return;
    final String url = widget.imageUrl.trim();
    if (url.isEmpty) {
      _fireReadyOnce();
      return;
    }

    _detachDecoder();
    final ImageProvider<Object> provider = CachedNetworkImageProvider(
      url,
      cacheManager: PhraseImageDiskCache.manager,
    );

    _listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        if (!mounted) return;
        final double w = info.image.width.toDouble();
        final double hPx = info.image.height.toDouble();
        if (w > 0 && hPx > 0 && widget.snapNaturalAspect) {
          setState(() => _widthOverHeight = w / hPx);
        }
        _fireReadyOnce();
        _detachDecoder();
      },
      onError: (_, __) {
        if (!mounted) return;
        if (widget.snapNaturalAspect) {
          setState(() => _widthOverHeight = widget.placeholderAspectRatio);
        }
        _fireReadyOnce();
        _detachDecoder();
      },
    );

    final ImageConfiguration config = createLocalImageConfiguration(context);
    _imageStream = provider.resolve(config);
    _imageStream!.addListener(_listener!);
  }

  Widget _fixedAspectChild({required BoxFit effectiveFit}) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: ColoredBox(
          color: const Color(0xFFF2F2F2),
          child: SupabasePhraseImage(
            imageUrl: widget.imageUrl,
            fit: effectiveFit,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.snapNaturalAspect ||
        widget.imageUrl.trim().isEmpty ||
        widget.maxImageHeight <= 0) {
      return _fixedAspectChild(effectiveFit: widget.fit);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double boundedW = constraints.maxWidth;
        if (!boundedW.isFinite || boundedW <= 1) {
          return _fixedAspectChild(effectiveFit: widget.fit);
        }

        if (_widthOverHeight == null) {
          final double fallbackH =
              boundedW / widget.placeholderAspectRatio.clamp(0.55, 2.5);
          return ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: SizedBox(
              width: boundedW,
              height: fallbackH,
              child: const WaitingTinPhotoLoader(),
            ),
          );
        }

        final double ratio = _widthOverHeight!;
        final double idealH = boundedW / ratio.clamp(0.34, 2.85);

        double h = idealH;
        BoxFit boxFit;

        if (idealH <= widget.maxImageHeight + 1) {
          h = idealH;
          boxFit = BoxFit.contain;
        } else {
          h = widget.maxImageHeight;
          boxFit = BoxFit.cover;
        }

        final double layoutHeight = h.clamp(120.0, widget.maxImageHeight);

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: ColoredBox(
            color: const Color(0xFFF2F2F2),
            child: SizedBox(
              width: boundedW,
              height: layoutHeight,
              child: SupabasePhraseImage(
                imageUrl: widget.imageUrl,
                fit: boxFit,
                alignment: Alignment.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
