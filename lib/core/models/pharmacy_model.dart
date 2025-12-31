import 'dart:math';

class PharmacyModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final String? openingHours;
  final double distanceKm;
  final String dataSource;

  /// Check if pharmacy is open now (simplified check)
  bool get isOpenNow {
    // Simplified: assume open if openingHours is not null
    // In production, parse openingHours and check current time
    return openingHours != null && openingHours!.isNotEmpty;
  }

  PharmacyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.openingHours,
    required this.distanceKm,
    this.dataSource = 'osm',
  });

  /// Create from Overpass API (OpenStreetMap) response
  static PharmacyModel? fromOverpass(
    Map<String, dynamic> json,
    double fromLat,
    double fromLon,
  ) {
    try {
      final tags = json['tags'] as Map<String, dynamic>? ?? {};
      
      // Get coordinates - handle both nodes and ways
      double lat;
      double lon;
      
      if (json['lat'] != null && json['lon'] != null) {
        // Node
        lat = (json['lat'] as num).toDouble();
        lon = (json['lon'] as num).toDouble();
      } else if (json['center'] != null) {
        // Way (building) - use center point
        lat = (json['center']['lat'] as num).toDouble();
        lon = (json['center']['lon'] as num).toDouble();
      } else {
        return null; // No valid coordinates
      }

      // Build address from OSM tags
      final address = _buildAddress(tags);
      
      // Calculate distance
      final distance = _calculateDistance(fromLat, fromLon, lat, lon);

      return PharmacyModel(
        id: json['id'].toString(),
        name: tags['name'] ?? tags['brand'] ?? 'Pharmacy',
        address: address,
        latitude: lat,
        longitude: lon,
        phone: tags['phone'] ?? tags['contact:phone'],
        website: tags['website'] ?? tags['contact:website'],
        openingHours: tags['opening_hours'],
        distanceKm: distance,
        dataSource: 'osm',
      );
    } catch (e) {
      return null;
    }
  }

  /// Build human-readable address from OSM tags
  static String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    
    // Street address
    if (tags['addr:housenumber'] != null && tags['addr:street'] != null) {
      parts.add('${tags['addr:housenumber']} ${tags['addr:street']}');
    } else if (tags['addr:street'] != null) {
      parts.add(tags['addr:street']);
    }
    
    // District/Suburb
    if (tags['addr:suburb'] != null) {
      parts.add(tags['addr:suburb']);
    } else if (tags['addr:district'] != null) {
      parts.add(tags['addr:district']);
    }
    
    // City
    if (tags['addr:city'] != null) {
      parts.add(tags['addr:city']);
    }
    
    // If no address parts, try to extract from name or return generic
    if (parts.isEmpty) {
      return tags['addr:full'] ?? 'Address not available';
    }
    
    return parts.join(', ');
  }

  /// Calculate distance between two points using Haversine formula
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radius in km
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c;
    
    return double.parse(distance.toStringAsFixed(2));
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Legacy OSM Nominatim parser (kept for compatibility)
  factory PharmacyModel.fromOsm(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['place_id'].toString(),
      name: json['name'] ?? 'Pharmacy',
      address: json['display_name'] ?? '',
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
      website: json['extratags']?['website'],
      phone: json['extratags']?['phone'] ?? json['extratags']?['contact:phone'],
      distanceKm: 0, // Unknown distance in legacy format
      dataSource: 'nominatim',
    );
  }

  /// Check if pharmacy is currently open (basic check)
  bool get is24Hours {
    return openingHours?.contains('24/7') ?? false;
  }

  /// Get formatted distance string
  String get distanceText {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toInt()} m';
    } else {
      return '$distanceKm km';
    }
  }
}
