/// Voice model representing an ElevenLabs voice
class VoiceModel {
  final String id;
  final String name;
  final String category;
  final String? description;
  final Map<String, dynamic>? labels;
  final String? previewUrl;
  
  VoiceModel({
    required this.id,
    required this.name,
    this.category = 'generated',
    this.description,
    this.labels,
    this.previewUrl,
  });
  
  /// Create from JSON response
  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      id: json['voice_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Unknown Voice',
      category: json['category'] ?? 'generated',
      description: json['description'],
      labels: json['labels'] as Map<String, dynamic>?,
      previewUrl: json['preview_url'],
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'description': description,
    'labels': labels,
    'previewUrl': previewUrl,
  };
  
  /// Get voice gender from labels
  String get gender {
    if (labels != null) {
      final genderLabel = labels!['gender'] ?? labels!['Gender'];
      if (genderLabel != null) return genderLabel.toString();
    }
    return 'unknown';
  }
  
  /// Get voice accent from labels
  String get accent {
    if (labels != null) {
      final accentLabel = labels!['accent'] ?? labels!['Accent'];
      if (accentLabel != null) return accentLabel.toString();
    }
    return 'unknown';
  }
  
  /// Get voice age from labels
  String get age {
    if (labels != null) {
      final ageLabel = labels!['age'] ?? labels!['Age'];
      if (ageLabel != null) return ageLabel.toString();
    }
    return 'unknown';
  }
  
  /// Get voice use case from labels
  String get useCase {
    if (labels != null) {
      final useCaseLabel = labels!['use case'] ?? labels!['Use Case'];
      if (useCaseLabel != null) return useCaseLabel.toString();
    }
    return 'general';
  }
  
  /// Get display name with gender/accent info
  String get displayName {
    final parts = [name];
    if (gender != 'unknown') parts.add(gender);
    if (accent != 'unknown') parts.add(accent);
    return parts.join(' • ');
  }
  
  @override
  String toString() => 'VoiceModel(id: $id, name: $name, gender: $gender, accent: $accent)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceModel && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
