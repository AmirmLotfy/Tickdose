import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../icons/app_icons.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  /// Upload image to Firebase Storage
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_images/$fileName');
      
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete profile image from Firebase Storage
  Future<void> deleteProfileImage(String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('profile_images/$fileName');
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
      if (!e.toString().contains('object-not-found')) {
        throw Exception('Failed to delete image: $e');
      }
    }
  }

  /// Show image source selection dialog
  Future<File?> showImageSourceDialog(dynamic context) async {
    return await showDialog<File?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(AppIcons.image()),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImageFromGallery();
                if (context.mounted && file != null) {
                  Navigator.pop(context, file);
                }
              },
            ),
            ListTile(
              leading: Icon(AppIcons.camera()),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImageFromCamera();
                if (context.mounted && file != null) {
                  Navigator.pop(context, file);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
