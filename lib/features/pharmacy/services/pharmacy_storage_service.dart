import 'package:hive_flutter/hive_flutter.dart';

class PharmacyStorageService {
  static const String _favoritesBoxName = 'pharmacy_favorites';
  
  Future<void> init() async {
    await Hive.openBox<String>(_favoritesBoxName);
  }

  Box<String> get _box => Hive.box<String>(_favoritesBoxName);

  List<String> getFavorites() {
    return _box.values.toList();
  }

  Future<void> toggleFavorite(String pharmacyId) async {
    if (isFavorite(pharmacyId)) {
      await _removeFavorite(pharmacyId);
    } else {
      await _addFavorite(pharmacyId);
    }
  }

  bool isFavorite(String pharmacyId) {
    return _box.values.contains(pharmacyId);
  }

  Future<void> _addFavorite(String pharmacyId) async {
    await _box.add(pharmacyId);
  }

  Future<void> _removeFavorite(String pharmacyId) async {
    final Map<dynamic, String> deliveriesMap = _box.toMap();
    dynamic desiredKey;
    deliveriesMap.forEach((key, value) {
        if (value == pharmacyId) {
            desiredKey = key;
        }
    });
    if (desiredKey != null) {
      await _box.delete(desiredKey);
    }
  }
}
