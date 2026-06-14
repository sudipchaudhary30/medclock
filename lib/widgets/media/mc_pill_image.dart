import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class McPillImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const McPillImage({
    super.key,
    required this.imageUrl,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
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
      return const Icon(
        Icons.medication_rounded,
        color: AppTheme.textHint,
        size: 30,
      );
    }
    if (imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.medication_rounded,
          color: AppTheme.textHint,
        ),
      );
    }
    // Assume local file path for captured pill photos
    return Image.file(
      File(imageUrl!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.medication_rounded,
        color: AppTheme.textHint,
      ),
    );
  }
}
