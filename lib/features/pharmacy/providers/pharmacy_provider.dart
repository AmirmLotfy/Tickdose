import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/features/pharmacy/services/pharmacy_service.dart';
import 'package:tickdose/features/pharmacy/services/pharmacy_storage_service.dart';
import 'package:tickdose/core/models/pharmacy_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// Services
final pharmacyServiceProvider = Provider<PharmacyService>((ref) => PharmacyService());
final pharmacyStorageServiceProvider = Provider<PharmacyStorageService>((ref) {
  // Service should be initialized in main or async provider
  return PharmacyStorageService();
});

// Location Provider
final currentLocationProvider = FutureProvider<LatLng>((ref) async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied forever');
    }
    
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    rethrow;
  }
});

// Favorites Notifier
class PharmacyFavoritesNotifier extends AsyncNotifier<List<String>> {
  late PharmacyStorageService _storage;

  @override
  Future<List<String>> build() async {
    _storage = ref.read(pharmacyStorageServiceProvider);
    await _storage.init();
    return _storage.getFavorites();
  }

  Future<void> toggleFavorite(String pharmacyId) async {
    // Optimistic update could be done here, but let's stick to safe async
    await _storage.toggleFavorite(pharmacyId);
    state = AsyncValue.data(_storage.getFavorites());
  }

  bool isFavorite(String pharmacyId) {
    return state.value?.contains(pharmacyId) ?? false;
  }
}

final favoritePharmaciesProvider = AsyncNotifierProvider<PharmacyFavoritesNotifier, List<String>>(PharmacyFavoritesNotifier.new);

// Pharmacies Data Provider
final pharmaciesProvider = FutureProvider<List<PharmacyModel>>((ref) async {
  final service = ref.watch(pharmacyServiceProvider);
  final location = await ref.watch(currentLocationProvider.future);
  
  return service.searchPharmacies(location.latitude, location.longitude);
});
