import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:forge/core/chat_theme.dart';

/// Full-screen image viewer with pinch-to-zoom and swipe-to-dismiss.
class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String senderName;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    this.senderName = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        title: senderName.isNotEmpty
            ? Text(senderName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
            : null,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            Navigator.pop(context);
          }
        },
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) => Center(
                child: CircularProgressIndicator(
                  color: ChatTheme.primaryLight,
                  strokeWidth: 2,
                ),
              ),
              errorWidget: (_, __, ___) => const Icon(
                Icons.broken_image_rounded,
                size: 64,
                color: Colors.white38,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
