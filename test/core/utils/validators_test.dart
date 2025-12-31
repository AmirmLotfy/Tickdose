import 'package:flutter_test/flutter_test.dart';
import 'package:tickdose/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('emailValidator', () {
      test('should return null for valid email', () {
        expect(Validators.emailValidator('user@example.com'), isNull);
        expect(Validators.emailValidator('test.email+tag@domain.co.uk'), isNull);
      });
      
      test('should return error for invalid email', () {
        expect(Validators.emailValidator('invalid'), isNotNull);
        expect(Validators.emailValidator('invalid@'), isNotNull);
        expect(Validators.emailValidator('@domain.com'), isNotNull);
        expect(Validators.emailValidator(''), isNotNull);
      });
    });
    
    group('passwordValidator', () {
      test('should return null for valid password', () {
        expect(Validators.passwordValidator('password123'), isNull);
        expect(Validators.passwordValidator('123456'), isNull);
      });
      
      test('should return error for short password', () {
        expect(Validators.passwordValidator('12345'), isNotNull);
        expect(Validators.passwordValidator(''), isNotNull);
      });
    });
    
    group('confirmPasswordValidator', () {
      test('should return null when passwords match', () {
        expect(Validators.confirmPasswordValidator('password123', 'password123'), isNull);
      });
      
      test('should return error when passwords do not match', () {
        expect(Validators.confirmPasswordValidator('password123', 'password456'), isNotNull);
      });
    });
    
    group('nameValidator', () {
      test('should return null for valid name', () {
        expect(Validators.nameValidator('John Doe'), isNull);
        expect(Validators.nameValidator('John'), isNull);
      });
      
      test('should return error for short name', () {
        expect(Validators.nameValidator('J'), isNotNull);
        expect(Validators.nameValidator(''), isNotNull);
      });
    });
    
    group('requiredValidator', () {
      test('should return null for non-empty value', () {
        expect(Validators.requiredValidator('value'), isNull);
        expect(Validators.requiredValidator('  value  '), isNull);
      });
      
      test('should return error for empty value', () {
        expect(Validators.requiredValidator(''), isNotNull);
        expect(Validators.requiredValidator('   '), isNotNull);
        expect(Validators.requiredValidator(null), isNotNull);
      });
    });
  });
}
