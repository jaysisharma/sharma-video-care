import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme_tokens.dart';

/// Product photo from a bundled asset (`assets/...`) or a URL, with a quiet
/// placeholder when there is no photo or it fails to load.
class SvcProductImage extends StatelessWidget {
  final String? source;
  final BoxFit fit;
  final double placeholderIconSize;

  const SvcProductImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.placeholderIconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final src = source;
    if (src == null || src.isEmpty) return _placeholder();
    if (src.startsWith('assets/')) {
      return Image.asset(src, fit: fit, errorBuilder: (_, __, ___) => _placeholder());
    }
    return CachedNetworkImage(
      imageUrl: src,
      fit: fit,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: SvcColors.surfaceSubtle,
      alignment: Alignment.center,
      child: Icon(Icons.photo_camera_outlined, size: placeholderIconSize, color: SvcColors.subtle),
    );
  }
}
