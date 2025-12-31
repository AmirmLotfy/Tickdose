import 'package:dio/dio.dart';
import 'package:tickdose/core/models/pharmacy_model.dart';
import 'package:tickdose/core/utils/logger.dart';

class PharmacyService {
  final Dio _dio = Dio();
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  /// Search for pharmacies near a location using Overpass API (OpenStreetMap)
  /// 
  /// [lat] Latitude of search center
  /// [lon] Longitude of search center
  /// [radiusKm] Search radius in kilometers (default: 5km)
  Future<List<PharmacyModel>> searchPharmacies(
    double lat,
    double lon, {
    double radiusKm = 5,
  }) async {
    try {
      // Build Overpass QL query for pharmacies
      // Searches for both nodes and ways (buildings) with amenity=pharmacy
      final query = '''
[out:json][timeout:25];
(
  node["amenity"="pharmacy"](around:${radiusKm * 1000},$lat,$lon);
  way["amenity"="pharmacy"](around:${radiusKm * 1000},$lat,$lon);
);
out center body;
''';

      Logger.info('Searching pharmacies within ${radiusKm}km of ($lat, $lon)', tag: 'Pharmacy');

      final response = await _dio.post(
        _overpassUrl,
        data: {'data': query},
        options: Options(
          headers: {
            'User-Agent': 'TickdoseApp/1.0',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> elements = data['elements'] ?? [];

        Logger.info('Found ${elements.length} pharmacies', tag: 'Pharmacy');

        final pharmacies = elements
            .map((json) => PharmacyModel.fromOverpass(json, lat, lon))
            .where((pharmacy) => pharmacy != null)
            .cast<PharmacyModel>()
            .toList();

        // Sort by distance
        pharmacies.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

        return pharmacies;
      } else {
        Logger.error('Overpass API error: ${response.statusCode}', tag: 'Pharmacy');
        return [];
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to search pharmacies: $e', tag: 'Pharmacy', stackTrace: stackTrace);
      return [];
    }
  }

  /// Search for 24-hour pharmacies specifically
  Future<List<PharmacyModel>> search24HourPharmacies(
    double lat,
    double lon, {
    double radiusKm = 10,
  }) async {
    try {
      final query = '''
[out:json][timeout:25];
(
  node["amenity"="pharmacy"]["opening_hours"="24/7"](around:${radiusKm * 1000},$lat,$lon);
  way["amenity"="pharmacy"]["opening_hours"="24/7"](around:${radiusKm * 1000},$lat,$lon);
);
out center body;
''';

      final response = await _dio.post(
        _overpassUrl,
        data: {'data': query},
        options: Options(
          headers: {
            'User-Agent': 'TickdoseApp/1.0',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> elements = data['elements'] ?? [];

        final pharmacies = elements
            .map((json) => PharmacyModel.fromOverpass(json, lat, lon))
            .where((pharmacy) => pharmacy != null)
            .cast<PharmacyModel>()
            .toList();

        pharmacies.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

        return pharmacies;
      }
      return [];
    } catch (e) {
      Logger.error('Failed to search 24h pharmacies: $e', tag: 'Pharmacy');
      return [];
    }
  }
}
