/// Validation utilities for Firestore data before writing
class FirestoreValidator {
  /// Validates medicine data before saving
  static Map<String, String>? validateMedicine(Map<String, dynamic> data) {
    final errors = <String, String>{};
    
    // Validate name
    if (!data.containsKey('name') || data['name'] == null) {
      errors['name'] = 'Medicine name is required';
    } else if (data['name'] is! String) {
      errors['name'] = 'Medicine name must be a string';
    } else {
      final name = data['name'] as String;
      if (name.trim().isEmpty) {
        errors['name'] = 'Medicine name cannot be empty';
      } else if (name.length > 200) {
        errors['name'] = 'Medicine name must be 200 characters or less';
      }
    }
    
    // Validate dosage
    if (!data.containsKey('dosage') || data['dosage'] == null) {
      errors['dosage'] = 'Dosage is required';
    } else if (data['dosage'] is! String) {
      errors['dosage'] = 'Dosage must be a string';
    } else {
      final dosage = data['dosage'] as String;
      if (dosage.trim().isEmpty) {
        errors['dosage'] = 'Dosage cannot be empty';
      } else if (dosage.length > 100) {
        errors['dosage'] = 'Dosage must be 100 characters or less';
      }
    }
    
    // Validate userId
    if (!data.containsKey('userId') || data['userId'] == null) {
      errors['userId'] = 'User ID is required';
    } else if (data['userId'] is! String || (data['userId'] as String).isEmpty) {
      errors['userId'] = 'User ID must be a non-empty string';
    }
    
    // Validate createdAt
    if (!data.containsKey('createdAt') || data['createdAt'] == null) {
      errors['createdAt'] = 'Created timestamp is required';
    }
    
    // Validate optional fields
    if (data.containsKey('notes') && data['notes'] != null) {
      if (data['notes'] is! String) {
        errors['notes'] = 'Notes must be a string';
      } else if ((data['notes'] as String).length > 1000) {
        errors['notes'] = 'Notes must be 1000 characters or less';
      }
    }
    
    return errors.isEmpty ? null : errors;
  }
  
  /// Validates reminder data before saving
  static Map<String, String>? validateReminder(Map<String, dynamic> data) {
    final errors = <String, String>{};
    
    // Validate medicineId
    if (!data.containsKey('medicineId') || data['medicineId'] == null) {
      errors['medicineId'] = 'Medicine ID is required';
    } else if (data['medicineId'] is! String || (data['medicineId'] as String).isEmpty) {
      errors['medicineId'] = 'Medicine ID must be a non-empty string';
    }
    
    // Validate time
    if (!data.containsKey('time') || data['time'] == null) {
      errors['time'] = 'Time is required';
    }
    
    // Validate userId
    if (!data.containsKey('userId') || data['userId'] == null) {
      errors['userId'] = 'User ID is required';
    } else if (data['userId'] is! String || (data['userId'] as String).isEmpty) {
      errors['userId'] = 'User ID must be a non-empty string';
    }
    
    // Validate createdAt
    if (!data.containsKey('createdAt') || data['createdAt'] == null) {
      errors['createdAt'] = 'Created timestamp is required';
    }
    
    return errors.isEmpty ? null : errors;
  }
  
  /// Validates medicine log data before saving
  static Map<String, String>? validateMedicineLog(Map<String, dynamic> data) {
    final errors = <String, String>{};
    
    // Validate medicineId
    if (!data.containsKey('medicineId') || data['medicineId'] == null) {
      errors['medicineId'] = 'Medicine ID is required';
    } else if (data['medicineId'] is! String || (data['medicineId'] as String).isEmpty) {
      errors['medicineId'] = 'Medicine ID must be a non-empty string';
    }
    
    // Validate status
    if (!data.containsKey('status') || data['status'] == null) {
      errors['status'] = 'Status is required';
    } else if (data['status'] is! String) {
      errors['status'] = 'Status must be a string';
    } else {
      final status = data['status'] as String;
      if (!['taken', 'missed', 'skipped'].contains(status)) {
        errors['status'] = 'Status must be one of: taken, missed, skipped';
      }
    }
    
    // Validate timestamp
    if (!data.containsKey('timestamp') && !data.containsKey('takenAt')) {
      errors['timestamp'] = 'Timestamp is required';
    }
    
    // Validate userId
    if (!data.containsKey('userId') || data['userId'] == null) {
      errors['userId'] = 'User ID is required';
    } else if (data['userId'] is! String || (data['userId'] as String).isEmpty) {
      errors['userId'] = 'User ID must be a non-empty string';
    }
    
    return errors.isEmpty ? null : errors;
  }
  
  /// Validates side effect data before saving
  static Map<String, String>? validateSideEffect(Map<String, dynamic> data) {
    final errors = <String, String>{};
    
    // Validate medicineId
    if (!data.containsKey('medicineId') || data['medicineId'] == null) {
      errors['medicineId'] = 'Medicine ID is required';
    } else if (data['medicineId'] is! String || (data['medicineId'] as String).isEmpty) {
      errors['medicineId'] = 'Medicine ID must be a non-empty string';
    }
    
    // Validate symptom
    if (!data.containsKey('symptom') || data['symptom'] == null) {
      errors['symptom'] = 'Symptom is required';
    } else if (data['symptom'] is! String) {
      errors['symptom'] = 'Symptom must be a string';
    } else {
      final symptom = data['symptom'] as String;
      if (symptom.trim().isEmpty) {
        errors['symptom'] = 'Symptom cannot be empty';
      } else if (symptom.length > 500) {
        errors['symptom'] = 'Symptom must be 500 characters or less';
      }
    }
    
    // Validate occurredAt
    if (!data.containsKey('occurredAt') || data['occurredAt'] == null) {
      errors['occurredAt'] = 'Occurred timestamp is required';
    }
    
    // Validate optional fields
    if (data.containsKey('notes') && data['notes'] != null) {
      if (data['notes'] is! String) {
        errors['notes'] = 'Notes must be a string';
      } else if ((data['notes'] as String).length > 1000) {
        errors['notes'] = 'Notes must be 1000 characters or less';
      }
    }
    
    if (data.containsKey('severity') && data['severity'] != null) {
      if (data['severity'] is! String) {
        errors['severity'] = 'Severity must be a string';
      } else {
        final severity = data['severity'] as String;
        if (!['mild', 'moderate', 'severe'].contains(severity.toLowerCase())) {
          errors['severity'] = 'Severity must be one of: mild, moderate, severe';
        }
      }
    }
    
    return errors.isEmpty ? null : errors;
  }
  
  /// Validates user profile data before saving
  static Map<String, String>? validateUserProfile(Map<String, dynamic> data) {
    final errors = <String, String>{};
    
    // Validate email
    if (!data.containsKey('email') || data['email'] == null) {
      errors['email'] = 'Email is required';
    } else if (data['email'] is! String) {
      errors['email'] = 'Email must be a string';
    } else {
      final email = data['email'] as String;
      if (email.trim().isEmpty) {
        errors['email'] = 'Email cannot be empty';
      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
        errors['email'] = 'Email must be a valid email address';
      }
    }
    
    // Validate displayName
    if (!data.containsKey('displayName') || data['displayName'] == null) {
      errors['displayName'] = 'Display name is required';
    } else if (data['displayName'] is! String) {
      errors['displayName'] = 'Display name must be a string';
    } else {
      final displayName = data['displayName'] as String;
      if (displayName.trim().isEmpty) {
        errors['displayName'] = 'Display name cannot be empty';
      } else if (displayName.length > 100) {
        errors['displayName'] = 'Display name must be 100 characters or less';
      }
    }
    
    // Validate createdAt
    if (!data.containsKey('createdAt') || data['createdAt'] == null) {
      errors['createdAt'] = 'Created timestamp is required';
    }
    
    return errors.isEmpty ? null : errors;
  }
}
