import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Provider for image service
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<ImageData?> pickFromCamera({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (photo == null) {
        return null;
      }

      return await _processImage(photo);
    } catch (e) {
      throw ImageException('Failed to capture photo: $e');
    }
  }

  /// Pick image from gallery
  Future<ImageData?> pickFromGallery({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (image == null) {
        return null;
      }

      return await _processImage(image);
    } catch (e) {
      throw ImageException('Failed to pick image: $e');
    }
  }

  /// Pick multiple images from gallery
  Future<List<ImageData>> pickMultipleFromGallery({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
    int limit = 5,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (images.isEmpty) {
        return [];
      }

      final List<ImageData> processedImages = [];
      for (var i = 0; i < images.length && i < limit; i++) {
        final imageData = await _processImage(images[i]);
        if (imageData != null) {
          processedImages.add(imageData);
        }
      }

      return processedImages;
    } catch (e) {
      throw ImageException('Failed to pick images: $e');
    }
  }

  /// Process and compress image
  Future<ImageData?> _processImage(XFile xFile) async {
    try {
      final File file = File(xFile.path);
      final int fileSize = await file.length();

      // If file is small enough, use it directly
      if (fileSize <= 1024 * 1024) {
        // 1MB
        return ImageData(
          file: file,
          path: file.path,
          size: fileSize,
          name: path.basename(file.path),
        );
      }

      // Otherwise, compress it
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw ImageException('Failed to decode image');
      }

      // Resize if too large
      img.Image resized = image;
      if (image.width > 1920 || image.height > 1080) {
        resized = img.copyResize(
          image,
          width: image.width > 1920 ? 1920 : null,
          height: image.height > 1080 ? 1080 : null,
        );
      }

      // Compress to JPEG with quality 85
      final compressed = img.encodeJpg(resized, quality: 85);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = path.join(tempDir.path, 'proof_$timestamp.jpg');
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(compressed);

      return ImageData(
        file: tempFile,
        path: tempFile.path,
        size: compressed.length,
        name: path.basename(tempFile.path),
      );
    } catch (e) {
      throw ImageException('Failed to process image: $e');
    }
  }

  /// Delete temporary image file
  Future<void> deleteImage(ImageData imageData) async {
    try {
      if (await imageData.file.exists()) {
        await imageData.file.delete();
      }
    } catch (e) {
      // Ignore deletion errors
    }
  }

  /// Convert image to base64 string for API upload
  Future<String> imageToBase64(ImageData imageData) async {
    try {
      final bytes = await imageData.file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw ImageException('Failed to convert image to base64: $e');
    }
  }
}

// Models
class ImageData {
  final File file;
  final String path;
  final int size;
  final String name;

  ImageData({
    required this.file,
    required this.path,
    required this.size,
    required this.name,
  });

  String get sizeInMB => (size / (1024 * 1024)).toStringAsFixed(2);

  bool get isValid => file.existsSync();
}

class ImageException implements Exception {
  final String message;

  ImageException(this.message);

  @override
  String toString() => message;
}

// Helper function
import 'dart:convert';

String base64Encode(List<int> bytes) {
  return const Base64Encoder().convert(bytes);
}
