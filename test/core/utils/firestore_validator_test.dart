import 'package:flutter_test/flutter_test.dart';
import 'package:tickdose/core/utils/firestore_validator.dart';

void main() {
  group('FirestoreValidator', () {
    group('validateMedicine', () {
      test('should return null for valid medicine data', () {
        final data = {
          'name': 'Aspirin',
          'dosage': '100mg',
          'userId': 'user123',
          'createdAt': DateTime.now(),
        };
        
        final errors = FirestoreValidator.validateMedicine(data);
        expect(errors, isNull);
      });
      
      test('should return errors for missing required fields', () {
        final data = {
          'name': 'Aspirin',
          // Missing dosage, userId, createdAt
        };
        
        final errors = FirestoreValidator.validateMedicine(data);
        expect(errors, isNotNull);
        expect(errors!['dosage'], isNotNull);
        expect(errors['userId'], isNotNull);
        expect(errors['createdAt'], isNotNull);
      });
      
      test('should return error for empty name', () {
        final data = {
          'name': '',
          'dosage': '100mg',
          'userId': 'user123',
          'createdAt': DateTime.now(),
        };
        
        final errors = FirestoreValidator.validateMedicine(data);
        expect(errors, isNotNull);
        expect(errors!['name'], isNotNull);
      });
      
      test('should return error for name too long', () {
        final data = {
          'name': 'A' * 201, // 201 characters
          'dosage': '100mg',
          'userId': 'user123',
          'createdAt': DateTime.now(),
        };
        
        final errors = FirestoreValidator.validateMedicine(data);
        expect(errors, isNotNull);
        expect(errors!['name'], contains('200 characters'));
      });
      
      test('should return error for notes too long', () {
        final data = {
          'name': 'Aspirin',
          'dosage': '100mg',
          'userId': 'user123',
          'createdAt': DateTime.now(),
          'notes': 'A' * 1001, // 1001 characters
        };
        
        final errors = FirestoreValidator.validateMedicine(data);
        expect(errors, isNotNull);
        expect(errors!['notes'], contains('1000 characters'));
      });
    });
    
    group('validateReminder', () {
      test('should return null for valid reminder data', () {
        final data = {
          'medicineId': 'med123',
          'time': '08:00',
          'userId': 'user123',
          'createdAt': DateTime.now(),
        };
        
        final errors = FirestoreValidator.validateReminder(data);
        expect(errors, isNull);
      });
      
      test('should return errors for missing required fields', () {
        final data = {
          'medicineId': 'med123',
          // Missing time, userId, createdAt
        };
        
        final errors = FirestoreValidator.validateReminder(data);
        expect(errors, isNotNull);
        expect(errors!['time'], isNotNull);
        expect(errors['userId'], isNotNull);
        expect(errors['createdAt'], isNotNull);
      });
    });
    
    group('validateMedicineLog', () {
      test('should return null for valid log data', () {
        final data = {
          'medicineId': 'med123',
          'status': 'taken',
          'timestamp': DateTime.now(),
          'userId': 'user123',
        };
        
        final errors = FirestoreValidator.validateMedicineLog(data);
        expect(errors, isNull);
      });
      
      test('should return error for invalid status', () {
        final data = {
          'medicineId': 'med123',
          'status': 'invalid_status',
          'timestamp': DateTime.now(),
          'userId': 'user123',
        };
        
        final errors = FirestoreValidator.validateMedicineLog(data);
        expect(errors, isNotNull);
        expect(errors!['status'], contains('taken, missed, skipped'));
      });
      
      test('should accept takenAt instead of timestamp', () {
        final data = {
          'medicineId': 'med123',
          'status': 'taken',
          'takenAt': DateTime.now(),
          'userId': 'user123',
        };
        
        final errors = FirestoreValidator.validateMedicineLog(data);
        expect(errors, isNull);
      });
    });
    
    group('validateSideEffect', () {
      test('should return null for valid side effect data', () {
        final data = {
          'medicineId': 'med123',
          'symptom': 'Headache',
          'occurredAt': DateTime.now(),
        };
        
        final errors = FirestoreValidator.validateSideEffect(data);
        expect(errors, isNull);
      });
      
      test('should return error for empty symptom', () {
        final data = {
          'medicineId': 'med123',
          'symptom': '',
          'occurredAt': DateTime.now(),
        };
        
        final errors = FirestoreValidator.validateSideEffect(data);
        expect(errors, isNotNull);
        expect(errors!['symptom'], isNotNull);
      });
      
      test('should return error for invalid severity', () {
        final data = {
          'medicineId': 'med123',
          'symptom': 'Headache',
          'occurredAt': DateTime.now(),
          'severity': 'invalid',
        };
        
        final errors = FirestoreValidator.validateSideEffect(data);
        expect(errors, isNotNull);
        expect(errors!['severity'], contains('mild, moderate, severe'));
      });
    });
    
    group('validateUserProfile', () {
      test('should return null for valid user profile data', () {
        final data = {
          'email': 'user@example.com',
          'displayName': 'John Doe',
          'createdAt': DateTime.now(),
        };
        
        final errors = FirestoreValidator.validateUserProfile(data);
        expect(errors, isNull);
      });
      
      test('should return error for invalid email', () {
        final data = {
          'email': 'invalid-email',
          'displayName': 'John Doe',
          'createdAt': DateTime.now(),
        };
        
        final errors = FirestoreValidator.validateUserProfile(data);
        expect(errors, isNotNull);
        expect(errors!['email'], contains('valid email'));
      });
      
      test('should return error for empty display name', () {
        final data = {
          'email': 'user@example.com',
          'displayName': '',
          'createdAt': DateTime.now(),
        };
        
        final errors = FirestoreValidator.validateUserProfile(data);
        expect(errors, isNotNull);
        expect(errors!['displayName'], isNotNull);
      });
    });
  });
}
