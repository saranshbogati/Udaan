import 'package:image_picker/image_picker.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<List<XFile>?> pickMultipleImages() async {
    try {
      return await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      print('Error picking images: $e');
      return null;
    }
  }

  static Future<XFile?> pickSingleImage({bool fromCamera = false}) async {
    try {
      return await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
