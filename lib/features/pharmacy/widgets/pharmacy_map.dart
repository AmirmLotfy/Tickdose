import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tickdose/core/models/pharmacy_model.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';

class PharmacyMap extends StatelessWidget {
  final List<PharmacyModel> pharmacies;
  final LatLng currentLocation;
  final Function(PharmacyModel) onPharmacyTap;

  const PharmacyMap({
    super.key,
    required this.pharmacies,
    required this.currentLocation,
    required this.onPharmacyTap,
  });

  /// Get map tile URL based on theme
  String _getTileUrl(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Use CartoDB tiles which have both light and dark variants
    if (isDark) {
      // Dark theme map tiles
      return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
    } else {
      // Light theme map tiles with subtle styling
      return 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FlutterMap(
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 14.0,
        minZoom: 10.0,
        maxZoom: 18.0,
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      children: [
        TileLayer(
          urlTemplate: _getTileUrl(context),
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.tickdose.app',
          maxZoom: 19,
        ),
        MarkerLayer(
          markers: [
            // Current Location Marker
            Marker(
              point: currentLocation,
              width: 50,
              height: 50,
              child: _CurrentLocationMarker(isDark: isDark),
            ),
            // Pharmacy Markers
            ...pharmacies.map((pharmacy) => Marker(
                  point: LatLng(pharmacy.latitude, pharmacy.longitude),
                  width: 50,
                  height: 50,
                  child: _PharmacyMarker(
                    isDark: isDark,
                    is24Hours: pharmacy.is24Hours,
                    onTap: () => onPharmacyTap(pharmacy),
                  ),
                )),
          ],
        ),
      ],
    );
  }
}

/// Custom branded current location marker
class _CurrentLocationMarker extends StatelessWidget {
  final bool isDark;

  const _CurrentLocationMarker({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark 
              ? AppColors.darkBackground 
              : AppColors.lightCard,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.my_location,
        color: AppColors.darkTextPrimary,
        size: 24,
      ),
    );
  }
}

/// Custom branded pharmacy marker matching app colors
class _PharmacyMarker extends StatelessWidget {
  final bool isDark;
  final bool is24Hours;
  final VoidCallback onTap;

  const _PharmacyMarker({
    required this.isDark,
    required this.is24Hours,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use primary teal for 24-hour pharmacies, primary blue for others
    final markerColor = is24Hours 
        ? AppColors.primaryTeal 
        : AppColors.primaryBlue;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark 
                ? AppColors.darkCard 
                : AppColors.lightCard,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: markerColor.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          AppIcons.pharmacy(),
          color: AppColors.darkTextPrimary,
          size: 28,
        ),
      ),
    );
  }
}
