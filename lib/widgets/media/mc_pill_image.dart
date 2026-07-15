import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McPillImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  /// When true the image will expand to fill the parent's width while
  /// keeping the provided `size` as height. Default false.
  final bool fitToParentWidth;

  const McPillImage({
    super.key,
    required this.imageUrl,
    this.size = 60,
    this.fitToParentWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fitToParentWidth ? double.infinity : size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(
        'assets/images/images.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.local_pharmacy_rounded,
          color: AppTheme.primaryColor,
          size: 36,
        ),
      );
    }
    if (imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.medication_rounded, color: AppTheme.textHint),
      );
    }
    // Assume local file path for captured pill photos
    return Image.file(
      File(imageUrl!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.medication_rounded, color: AppTheme.textHint),
    );
  }
}
