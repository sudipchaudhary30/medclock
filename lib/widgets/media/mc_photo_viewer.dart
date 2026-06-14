import 'dart:io';
import 'package:flutter/material.dart';
import '../layout/mc_app_bar.dart';

class McPhotoViewer extends StatelessWidget {
  final String imageUrl;

  const McPhotoViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const McAppBar(
        title: 'Photo Proof',
        showBackButton: true,
      ),
      body: Center(
        child: InteractiveViewer(
          child: imageUrl.startsWith('http')
              ? Image.network(imageUrl, fit: BoxFit.contain)
              : Image.file(File(imageUrl), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
