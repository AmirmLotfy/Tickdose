import 'package:flutter/material.dart';
import 'package:tickdose/core/models/pharmacy_model.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class PharmacyListView extends StatelessWidget {
  final List<PharmacyModel> pharmacies;
  final Function(PharmacyModel) onPharmacyTap;

  const PharmacyListView({
    super.key,
    required this.pharmacies,
    required this.onPharmacyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pharmacies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.pharmacy(), size: 64, color: AppColors.textTertiary(context)),
            const SizedBox(height: 16),
            Text(
              'No pharmacies found nearby',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try increasing the search radius',
              style: TextStyle(
                color: AppColors.textTertiary(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
      itemCount: pharmacies.length,
      itemBuilder: (context, index) {
        final pharmacy = pharmacies[index];
        return _PharmacyCard(
          pharmacy: pharmacy,
          onTap: () => onPharmacyTap(pharmacy),
        );
      },
    );
  }
}

class _PharmacyCard extends StatelessWidget {
  final PharmacyModel pharmacy;
  final VoidCallback onTap;

  const _PharmacyCard({
    required this.pharmacy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name + Distance
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      AppIcons.pharmacy(),
                      color: AppColors.primaryTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharmacy.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pharmacy.distanceText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (pharmacy.is24Hours)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.open24Hours,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(AppIcons.location(), size: 14, color: AppColors.textSecondary(context)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pharmacy.address,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // Opening Hours
              if (pharmacy.openingHours != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      AppIcons.time(),
                      size: 14,
                      color: pharmacy.is24Hours ? AppColors.successGreen : AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pharmacy.openingHours!,
                        style: TextStyle(
                          fontSize: 13,
                          color: pharmacy.is24Hours ? AppColors.successGreen : AppColors.textSecondary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Quick Actions
              const SizedBox(height: 12),
              Row(
                children: [
                  _QuickActionChip(
                    icon: AppIcons.directions(),
                    label: 'Directions',
                    onTap: () {
                      final url = 'https://www.google.com/maps/search/?api=1&query=${pharmacy.latitude},${pharmacy.longitude}';
                      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    },
                  ),
                  if (pharmacy.phone != null) ...[
                    const SizedBox(width: 8),
                    _QuickActionChip(
                      icon: AppIcons.phone(),
                      label: 'Call',
                      onTap: () {
                        launchUrl(Uri.parse('tel:${pharmacy.phone}'));
                      },
                    ),
                  ],
                  const Spacer(),
                  AppIcons.themedIcon(context, AppIcons.chevronRight(), color: AppColors.textSecondary(context), size: 20, autoMirror: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryBlue),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
