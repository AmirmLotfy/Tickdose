import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/core/utils/retry_helper.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add document
  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    return await RetryHelper.retry(
      operation: () async {
        final docRef = await _firestore.collection(collection).add(data);
        Logger.info('Document added: ${docRef.id}', tag: 'Firestore');
        return docRef.id;
      },
      retryable: RetryHelper.isFirestoreRetryableError,
      maxRetries: 3,
    ).catchError((e, stackTrace) {
      Logger.error('Failed to add document after retries', tag: 'Firestore', error: e, stackTrace: stackTrace);
      throw Exception('Failed to add document: ${e.toString()}');
    });
  }

  // Update document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    return await RetryHelper.retry(
      operation: () async {
        await _firestore.collection(collection).doc(docId).update(data);
        Logger.info('Document updated: $docId', tag: 'Firestore');
      },
      retryable: RetryHelper.isFirestoreRetryableError,
      maxRetries: 3,
    ).catchError((e, stackTrace) {
      Logger.error('Failed to update document after retries', tag: 'Firestore', error: e, stackTrace: stackTrace);
      throw Exception('Failed to update document: ${e.toString()}');
    });
  }

  // Delete document
  Future<void> deleteDocument(String collection, String docId) async {
    return await RetryHelper.retry(
      operation: () async {
        await _firestore.collection(collection).doc(docId).delete();
        Logger.info('Document deleted: $docId', tag: 'Firestore');
      },
      retryable: RetryHelper.isFirestoreRetryableError,
      maxRetries: 3,
    ).catchError((e, stackTrace) {
      Logger.error('Failed to delete document after retries', tag: 'Firestore', error: e, stackTrace: stackTrace);
      throw Exception('Failed to delete document: ${e.toString()}');
    });
  }

  // Get document
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await RetryHelper.retry(
      operation: () => _firestore.collection(collection).doc(docId).get(),
      retryable: RetryHelper.isFirestoreRetryableError,
      maxRetries: 3,
    ).catchError((e, stackTrace) {
      Logger.error('Failed to get document after retries', tag: 'Firestore', error: e, stackTrace: stackTrace);
      throw Exception('Failed to get document: ${e.toString()}');
    });
  }

  // Query documents
  Future<QuerySnapshot> queryDocuments(
    String collection, {
    List<Filter>? filters,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    return await RetryHelper.retry(
      operation: () async {
        Query query = _firestore.collection(collection);

        if (filters != null) {
          for (final filter in filters) {
            query = query.where(filter);
          }
        }

        if (limit != null) {
          query = query.limit(limit);
        }

        if (startAfter != null) {
          query = query.startAfterDocument(startAfter);
        }

        return await query.get();
      },
      retryable: RetryHelper.isFirestoreRetryableError,
      maxRetries: 3,
    ).catchError((e, stackTrace) {
      Logger.error('Failed to query documents after retries', tag: 'Firestore', error: e, stackTrace: stackTrace);
      throw Exception('Failed to query documents: ${e.toString()}');
    });
  }

  // Stream documents
  Stream<QuerySnapshot> streamDocuments(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Stream single document
  Stream<DocumentSnapshot> streamDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  // Batch operations
  WriteBatch batch() {
    return _firestore.batch();
  }

  // Transaction
  Future<T> runTransaction<T>(TransactionHandler<T> transactionHandler) {
    return _firestore.runTransaction(transactionHandler);
  }
}
