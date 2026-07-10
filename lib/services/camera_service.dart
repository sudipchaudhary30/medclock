import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Captures a photo and copies it to the application's documents
  /// directory so the file persists across app restarts and logouts.
  Future<String?> capturePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String ext = image.path.contains('.')
          ? '.${image.path.split('.').last}'
          : '';
      final String filename =
          'medclock_${DateTime.now().millisecondsSinceEpoch}$ext';
      final String destPath =
          '${appDir.path}${Platform.pathSeparator}$filename';

      final File saved = await File(image.path).copy(destPath);
      return saved.path;
    } catch (_) {
      return null;
    }
  }
}
