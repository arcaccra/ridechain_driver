
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerService {

  ImagePicker imagePicker = ImagePicker();

  captureImage(ImageSource? source) async {
    var pickedImage =  await imagePicker.pickImage(source: source!);
    return pickedImage;
  }

  Future<PlatformFile?> pickDocument({
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'doc', 'docx'],
        allowMultiple: allowMultiple,
        withData: false, // Don't load file data into memory (better for large files)
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }
}