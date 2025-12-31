import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MedicineCameraService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Capture image from camera
  Future<File?> captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to capture from camera: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick from gallery: $e');
    }
  }

  /// Upload medicine image to Firebase Storage
  /// Returns the download URL
  Future<String> uploadMedicineImage(File imageFile, String userId, String medicineId) async {
    try {
      final String fileName = 'medicine_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('medicines/$userId/$medicineId/$fileName');

      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete medicine image from Firebase Storage
  Future<void> deleteMedicineImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Image might already be deleted or URL invalid
      // Log but don't throw to prevent blocking medicine deletion
      Logger.warning('Failed to delete image: $e');
    }
  }

  /// Delete all images for a medicine
  Future<void> deleteAllMedicineImages(String userId, String medicineId) async {
    try {
      final Reference ref = _storage.ref().child('medicines/$userId/$medicineId');
      final ListResult result = await ref.listAll();

      for (final Reference fileRef in result.items) {
        await fileRef.delete();
      }
    } catch (e) {
      Logger.error('Failed to delete medicine images: $e');
    }
  }
}
