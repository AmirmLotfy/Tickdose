import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/core/utils/retry_helper.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file
  Future<String?> uploadFile(File file, String path) async {
    return await RetryHelper.retry(
      operation: () async {
        final ref = _storage.ref().child(path);
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        
        Logger.info('File uploaded: $path', tag: 'Storage');
        return downloadUrl;
      },
      retryable: RetryHelper.isNetworkError,
      maxRetries: 2, // Fewer retries for file uploads
    ).catchError((e, stackTrace) {
      Logger.error('Failed to upload file after retries', tag: 'Storage', error: e, stackTrace: stackTrace);
      return '';
    });
  }

  // Delete file
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
      Logger.info('File deleted: $path', tag: 'Storage');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete file', tag: 'Storage', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get download URL
  Future<String?> getDownloadURL(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e, stackTrace) {
      Logger.error('Failed to get download URL', tag: 'Storage', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(File file, String userId) async {
    final path = 'users/$userId/profile.jpg';
    return await uploadFile(file, path);
  }

  // Upload medicine image
  Future<String?> uploadMedicineImage(File file, String userId, String medicineId) async {
    final path = 'users/$userId/medicines/$medicineId.jpg';
    return await uploadFile(file, path);
  }

  // Upload voice message (from bytes)
  Future<String> uploadVoiceMessage({
    required String reminderId,
    required List<int> audioBytes,
    String userId = '', // Will be determined from auth context
  }) async {
    try {
      final path = 'voice_messages/$userId/$reminderId/${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(
        Uint8List.fromList(audioBytes),
        SettableMetadata(contentType: 'audio/m4a'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      Logger.info('Voice message uploaded: $path', tag: 'Storage');
      return downloadUrl;
    } catch (e, stackTrace) {
      Logger.error('Failed to upload voice message', tag: 'Storage', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

