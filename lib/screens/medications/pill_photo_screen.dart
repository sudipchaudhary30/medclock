import 'dart:io';
import 'package:flutter/material.dart';
import '../../widgets/layout/mc_scaffold.dart';

class PillPhotoScreen extends StatelessWidget {
  const PillPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String imagePath = ModalRoute.of(context)!.settings.arguments as String;

    return McScaffold(
      title: 'Pill Photo',
      showBackButton: true,
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
