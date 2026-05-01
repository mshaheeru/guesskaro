import 'package:flutter/material.dart';

/// Shared phrase image widget with shimmer placeholder + graceful error UI.
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

    return Image.network(
      imageUrl,
      fit: fit,
      alignment: alignment,
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        if (loadingProgress == null) return child;
        return const _ThreeDotsLoader();
      },
      errorBuilder: (BuildContext _, Object __, StackTrace? ___) => _errorBox(),
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

class _ThreeDotsLoader extends StatelessWidget {
  const _ThreeDotsLoader();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF0F0F0),
      child: Center(
        child: Text(
          '...',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}
