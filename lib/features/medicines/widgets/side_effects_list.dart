import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/medicines/providers/side_effect_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class SideEffectsListWidget extends ConsumerWidget {
  final MedicineModel medicine;

  const SideEffectsListWidget({super.key, required this.medicine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    
    if (user == null) {
      return Center(child: Text(AppLocalizations.of(context)!.pleaseLogInToViewSideEffects));
    }

    return StreamBuilder(
      stream: ref.watch(sideEffectServiceProvider).watchSideEffectsForMedicine(user.uid, medicine.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(AppLocalizations.of(context)!.errorLoadingSideEffects(snapshot.error ?? 'Unknown error')));
        }

        final sideEffects = snapshot.data ?? [];

        if (sideEffects.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.check(),
                    size: 64,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No side effects logged',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great! No adverse reactions reported for this medicine.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textTertiary(context)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sideEffects.length,
          itemBuilder: (context, index) {
            final effect = sideEffects[index];
            final severityColor = effect.severity == 'severe'
                ? AppColors.errorRed
                : effect.severity == 'moderate'
                    ? AppColors.warningOrange
                    : AppColors.successGreen;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: severityColor.withValues(alpha: 0.2),
                  child: Icon(
                    effect.severity == 'severe'
                        ? AppIcons.warning()
                        : effect.severity == 'moderate'
                            ? AppIcons.info()
                            : AppIcons.check(),
                    color: severityColor,
                  ),
                ),
                title: Text(
                  effect.symptom,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: severityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            effect.severity.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d, h:mm a', Localizations.localeOf(context).toString()).format(effect.occurredAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary(context),
                          ),
                        ),
                      ],
                    ),
                    if (effect.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        effect.notes,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(AppIcons.delete(), color: AppColors.errorRed),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.deleteSideEffectQuestion),
                        content: Text(AppLocalizations.of(context)!.deleteSideEffectWarning),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.errorRed,
                            ),
                            child: Text(AppLocalizations.of(context)!.delete),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      await ref
                          .read(sideEffectControllerProvider.notifier)
                          .deleteSideEffect(user.uid, effect.id);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.sideEffectDeleted)),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
