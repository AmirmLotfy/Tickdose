import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/services/doctor_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/doctors/models/doctor_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class EmergencySheet {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).value;
    List<Doctor> doctors = [];

    if (user != null) {
      try {
        final doctorService = DoctorService(user.uid);
        // We use 'first' to get the current snapshot data once
        doctors = await doctorService.getDoctors().first;
      } catch (e) {
        // Ignore error, just show 911
      }
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(AppIcons.warning(), color: AppColors.errorRed, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Emergency Assistance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'For immediate life-threatening emergencies, please call emergency services.',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            
            // Call 911 Button
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final uri = Uri(scheme: 'tel', path: '911');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.phone_in_talk),
              label: const Text('Call 911'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: AppColors.darkTextPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            if (doctors.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Contact Your Doctors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              ...doctors.map((doctor) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                    style: const TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
                title: Text(doctor.name),
                subtitle: Text(doctor.specialization),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.call, color: AppColors.successGreen),
                      onPressed: () async {
                        Navigator.pop(context);
                        final uri = Uri(scheme: 'tel', path: doctor.phoneNumber);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.message, color: AppColors.infoBlue), // WhatsApp/SMS generic icon
                      onPressed: () async {
                        Navigator.pop(context);
                        // Try launching WhatsApp
                        // Construct whatsapp URI
                        // Clean number: remove + if present for whatsapp url scheme usually, but 'https://wa.me/number' works with E.164
                        String phone = doctor.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
                        // Remove '+' for wa.me? No, wa.me expects country code without + usually? 
                        // Actually wa.me/15551234567
                        if (phone.startsWith('+')) {
                          phone = phone.substring(1);
                        }
                        
                        final whatsappUri = Uri.parse('https://wa.me/$phone');
                        if (await canLaunchUrl(whatsappUri)) {
                          await launchUrl(whatsappUri);
                        } else {
                          // Fallback to SMS
                           final smsUri = Uri(scheme: 'sms', path: doctor.phoneNumber);
                           if (await canLaunchUrl(smsUri)) {
                             await launchUrl(smsUri);
                           }
                        }
                      },
                    ),
                  ],
                ),
              )),
            ],
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
