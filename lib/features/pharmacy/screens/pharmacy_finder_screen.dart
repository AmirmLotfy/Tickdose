import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/core/widgets/permission_dialog.dart';
import 'package:tickdose/features/pharmacy/widgets/pharmacy_map.dart';
import 'package:tickdose/features/pharmacy/widgets/pharmacy_list_view.dart';
import 'package:tickdose/core/models/pharmacy_model.dart';
import 'package:tickdose/features/pharmacy/providers/pharmacy_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class PharmacyFinderScreen extends ConsumerStatefulWidget {
  const PharmacyFinderScreen({super.key});

  @override
  ConsumerState<PharmacyFinderScreen> createState() => _PharmacyFinderScreenState();
}

class _PharmacyFinderScreenState extends ConsumerState<PharmacyFinderScreen> {
  bool _showList = false; // false = map, true = list
  String _searchQuery = '';
  String _selectedFilter = 'Open Now';
  final TextEditingController _searchController = TextEditingController();
  PharmacyModel? _selectedPharmacy;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pharmaciesAsync = ref.watch(pharmaciesProvider);
    final locationAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: locationAsync.when(
        data: (currentLocation) {
          return pharmaciesAsync.when(
            data: (allPharmacies) {
              // Filter pharmacies based on search and filter
              final filteredPharmacies = _filterPharmacies(allPharmacies);
              
              // Select first pharmacy if none selected
              if (_selectedPharmacy == null && filteredPharmacies.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => _selectedPharmacy = filteredPharmacies.first);
                });
              }

              return Stack(
                children: [
                  // Full Screen Map Background
                  if (!_showList)
                    _buildMapBackground(context, filteredPharmacies, currentLocation),
                  if (_showList)
                    _buildListView(context, filteredPharmacies),
                  
                  // Top Layer: Search & Controls
                  _buildTopControls(context, filteredPharmacies),
                  
                  // Bottom Sheet: Pharmacy Details
                  if (_selectedPharmacy != null && !_showList)
                    _buildPharmacyDetailsSheet(context, _selectedPharmacy!),
                  
                  // Map Controls Floating Right
                  if (!_showList)
                    _buildMapControls(context),
                  
                  // Floating Bottom Navigation
                  _buildBottomNav(context),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text(AppLocalizations.of(context)!.pharmacyError(e))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => _buildLocationError(context, ref),
      ),
    );
  }

  List<PharmacyModel> _filterPharmacies(List<PharmacyModel> pharmacies) {
    var filtered = pharmacies;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               p.address.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply filter buttons
    if (_selectedFilter == 'Open Now') {
      // Filter for pharmacies open now (simplified - check if current time is within hours)
      filtered = filtered.where((p) => p.isOpenNow).toList();
    } else if (_selectedFilter == '24/7') {
      filtered = filtered.where((p) => p.is24Hours).toList();
    }
    // Drive-thru filter would need additional data

    return filtered;
  }

  Widget _buildMapBackground(BuildContext context, List<PharmacyModel> pharmacies, LatLng currentLocation) {
    return Stack(
      children: [
        // Map
                    PharmacyMap(
                      pharmacies: pharmacies,
                      currentLocation: currentLocation,
                      onPharmacyTap: (pharmacy) {
            setState(() => _selectedPharmacy = pharmacy);
          },
        ),
        // Map Pins Overlay
        ..._buildMapPins(context, pharmacies),
      ],
    );
  }

  List<Widget> _buildMapPins(BuildContext context, List<PharmacyModel> pharmacies) {
    if (pharmacies.isEmpty) return [];
    
    final widgets = <Widget>[];
    
    // Active Pin (first pharmacy)
    if (_selectedPharmacy != null) {
      widgets.add(
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: MediaQuery.of(context).size.width * 0.5,
          child: Transform.translate(
            offset: const Offset(-24, -24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_pharmacy,
                    color: AppColors.darkTextPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Inactive Pins (other pharmacies)
    for (var i = 0; i < pharmacies.length && i < 2; i++) {
      if (pharmacies[i].id != _selectedPharmacy?.id) {
        widgets.add(
          Positioned(
            top: MediaQuery.of(context).size.height * (0.3 + i * 0.25),
            left: MediaQuery.of(context).size.width * (0.2 + i * 0.35),
            child: Opacity(
              opacity: 0.7,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.local_pharmacy,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

  Widget _buildListView(BuildContext context, List<PharmacyModel> pharmacies) {
    return PharmacyListView(
      pharmacies: pharmacies,
      onPharmacyTap: (pharmacy) {
        setState(() {
          _selectedPharmacy = pharmacy;
          _showList = false;
        });
      },
    );
  }

  Widget _buildTopControls(BuildContext context, List<PharmacyModel> pharmacies) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundColor(context).withValues(alpha: 0.9),
              AppColors.backgroundColor(context).withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(context),
            const SizedBox(height: 12),
            // Filters & Toggle Row
            _buildFiltersRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight(context),
          width: 1,
        ),
        color: AppColors.backgroundColor(context).withValues(alpha: 0.6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(
                  Icons.search,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search pharmacies, meds...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: AppColors.borderLight(context),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.mic,
                  color: AppColors.textPrimary(context),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context) {
    final filters = ['Open Now', '24/7', 'Drive-thru'];
    
    return Row(
      children: [
        // Filters
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                final isActive = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryGreen
                            : AppColors.backgroundColor(context).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: isActive
                            ? null
                            : Border.all(
                                color: AppColors.borderLight(context),
                                width: 1,
                              ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Center(
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.backgroundColor(context)
                                    : AppColors.textPrimary(context),
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Map/List Toggle
        Container(
          height: 32,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor(context).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.borderLight(context),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton(context, 'Map', !_showList),
                  _buildToggleButton(context, 'List', _showList),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(BuildContext context, String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _showList = label == 'List'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.borderLight(context) : Colors.transparent, // transparent is acceptable here for toggle background
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.textPrimary(context)
                  : AppColors.textSecondary(context),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyDetailsSheet(BuildContext context, PharmacyModel pharmacy) {
    return Positioned(
      bottom: 100,
                      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor(context).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                    width: 48,
                    height: 4,
                        decoration: BoxDecoration(
                      color: AppColors.textPrimary(context).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pharmacy.name,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pharmacy.address,
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Rating
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.borderLight(context),
                                  borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                                    Text(
                                      '4.8',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                            Icon(
                                      Icons.star,
                                      color: AppColors.primaryGreen,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '(1.2k)',
                                style: TextStyle(
                                  color: AppColors.textTertiary(context),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Status & Distance
                      Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                                'Open until 9:00 PM',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 12,
                            color: AppColors.textPrimary(context).withValues(alpha: 0.2),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.straighten,
                                color: AppColors.textSecondary(context),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pharmacy.distanceText,
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final url = 'https://www.google.com/maps/search/?api=1&query=${pharmacy.latitude},${pharmacy.longitude}';
                                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              },
                              icon: const Icon(Icons.navigation, size: 18),
                              label: const Text('Get Directions'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: AppColors.backgroundColor(context),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            context,
                            Icons.call,
                            () {
                              if (pharmacy.phone != null) {
                                launchUrl(Uri.parse('tel:${pharmacy.phone}'));
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context,
                            Icons.share,
                            () {
                              // Share functionality
                            },
                          ),
                        ],
                      ),
                    ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.borderLight(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary(context),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMapControls(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 200,
      child: Column(
        children: [
          _buildMapControlButton(context, Icons.my_location),
          const SizedBox(height: 12),
          _buildMapControlButton(context, Icons.layers),
        ],
      ),
    );
  }

  Widget _buildMapControlButton(BuildContext context, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(context).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderLight(context),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: IconButton(
            icon: Icon(icon, color: AppColors.textPrimary(context), size: 20),
            onPressed: () {
              // Map control actions
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor(context).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home, 'Home', false),
                _buildNavItem(context, Icons.notifications, 'Remind', false),
                _buildNavItem(context, Icons.favorite, 'Track', false),
                _buildNavItem(context, Icons.local_pharmacy, 'Pharm', true),
                _buildNavItem(context, Icons.person, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        // Navigation logic
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primaryGreen : AppColors.textSecondary(context),
                size: 24,
              ),
              if (isActive)
                Positioned(
                  bottom: -4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primaryGreen : AppColors.textSecondary(context),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationError(BuildContext context, WidgetRef ref) {
    return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                  AppColors.primaryGreen.withValues(alpha: 0.1),
                  AppColors.primaryGreen.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
              Icons.location_off,
                  size: 50,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.locationAccessRequired,
                style: AppTextStyles.h3(context),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  AppLocalizations.of(context)!.locationAccessRationale,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await PermissionDialog.showLocationPermission(
                    context,
                    onGrant: () async {
                      final permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.whileInUse ||
                          permission == LocationPermission.always) {
                        ref.invalidate(currentLocationProvider);
                      }
                    },
                    onDeny: () {
                      // User declined, do nothing
                    },
                  );
                },
                icon: Icon(AppIcons.location()),
                label: Text(AppLocalizations.of(context)!.enableLocationAction),
                style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.backgroundColor(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
