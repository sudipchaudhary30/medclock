import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Captures a photo and copies it to the application's documents
  /// directory so the file persists across app restarts and logouts.
  Future<String?> capturePhoto() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted && !status.isLimited) return null;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;

      return _saveImageToDocuments(image, prefix: 'medclock_');
    } catch (_) {
      return null;
    }
  }

  /// Picks a photo from the device gallery and copies it to the application's
  /// documents directory so the file persists across app restarts and logouts.
  Future<String?> pickFromGallery() async {
    try {
      final status = await _requestGalleryPermission();
      if (!status.isGranted && !status.isLimited) return null;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;

      return _saveImageToDocuments(image, prefix: 'medclock_gallery_');
    } catch (_) {
      return null;
    }
  }

  Future<String?> _saveImageToDocuments(
    XFile image, {
    required String prefix,
  }) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String ext = image.path.contains('.')
        ? '.${image.path.split('.').last}'
        : '';
    final String filename =
        '$prefix${DateTime.now().millisecondsSinceEpoch}$ext';
    final String destPath = '${appDir.path}${Platform.pathSeparator}$filename';

    final File saved = await File(image.path).copy(destPath);
    return saved.path;
  }

  /// Requests permission to access device storage/gallery.
  Future<PermissionStatus> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) {
        return status;
      }
      return await Permission.storage.request();
    } else if (Platform.isIOS) {
      return await Permission.photos.request();
    }
    return PermissionStatus.granted;
  }
}
