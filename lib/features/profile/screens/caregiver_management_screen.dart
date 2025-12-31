import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/models/caregiver_model.dart';
import 'package:tickdose/core/services/caregiver_service.dart';
import 'package:tickdose/core/services/caregiver_sharing_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

final caregiversProvider = StreamProvider.family<List<CaregiverModel>, String>((ref, userId) {
  final service = CaregiverService();
  return service.watchCaregivers(userId);
});

class CaregiverManagementScreen extends ConsumerWidget {
  const CaregiverManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Caregivers')),
        body: const Center(child: Text('Please sign in')),
      );
    }

    final caregiversAsync = ref.watch(caregiversProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregivers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: caregiversAsync.when(
        data: (caregivers) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Manage Caregivers',
                style: AppTextStyles.h2(context),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your medication schedule with family members or caregivers.',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Add caregiver button
              ElevatedButton.icon(
                onPressed: () => _showAddCaregiverDialog(context, ref, user.uid),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Caregiver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              // Caregivers list
              if (caregivers.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 60,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No caregivers added',
                          style: AppTextStyles.h3(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add family members or caregivers to help manage your medications',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...caregivers.map((caregiver) => _buildCaregiverCard(context, ref, caregiver)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildCaregiverCard(BuildContext context, WidgetRef ref, CaregiverModel caregiver) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
          child: const Icon(Icons.person, color: AppColors.primaryBlue),
        ),
        title: Text(caregiver.caregiverName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(caregiver.caregiverEmail),
            const SizedBox(height: 4),
            Text(
              'Relationship: ${caregiver.relationship}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: caregiver.permissions.map((perm) {
                return Chip(
                  label: Text(
                    perm.name.split(RegExp(r'(?=[A-Z])')).join(' '),
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit Permissions'),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  if (context.mounted) {
                    _showEditPermissionsDialog(context, ref, caregiver);
                  }
                });
              },
            ),
            PopupMenuItem(
              child: const Text('Remove', style: TextStyle(color: AppColors.errorRed)),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  if (context.mounted) {
                    _showRemoveCaregiverDialog(context, ref, caregiver);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCaregiverDialog(BuildContext context, WidgetRef ref, String userId) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final relationshipController = TextEditingController();
    final selectedPermissions = <CaregiverPermission>[
      CaregiverPermission.viewMedications,
      CaregiverPermission.receiveAlerts,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Caregiver'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'caregiver@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.nameLabel,
                    hintText: AppLocalizations.of(context)!.nameLabel,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: 'family',
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.relationship),
                  items: [
                    DropdownMenuItem(value: 'family', child: Text(AppLocalizations.of(context)!.family)),
                    DropdownMenuItem(value: 'friend', child: Text(AppLocalizations.of(context)!.friend)),
                    DropdownMenuItem(value: 'nurse', child: Text(AppLocalizations.of(context)!.nurse)),
                    DropdownMenuItem(value: 'other', child: Text(AppLocalizations.of(context)!.other)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      relationshipController.text = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.permissions,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...CaregiverPermission.values.map((permission) {
                  return CheckboxListTile(
                    title: Text(permission.name.split(RegExp(r'(?=[A-Z])')).join(' ')),
                    value: selectedPermissions.contains(permission),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedPermissions.add(permission);
                        } else {
                          selectedPermissions.remove(permission);
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final l10n = AppLocalizations.of(context)!;
                if (emailController.text.isNotEmpty && nameController.text.isNotEmpty) {
                  if (selectedPermissions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.selectAtLeastOnePermission),
                        backgroundColor: AppColors.warningOrange,
                      ),
                    );
                    return;
                  }

                  try {
                    final sharingService = CaregiverSharingService();
                    final token = await sharingService.createInvitation(
                      userId: userId,
                      caregiverEmail: emailController.text.trim(),
                      permissions: selectedPermissions,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      // Show QR code screen
                      Navigator.pushNamed(
                        context,
                        Routes.caregiverInvitationQR,
                        arguments: {
                          'token': token,
                          'caregiverEmail': emailController.text.trim(),
                        },
                      );
                    }
                  } catch (e) {
                    Logger.error('Error creating invitation: $e', tag: 'CaregiverManagement');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l10n.errorGeneric}: $e')),
                      );
                    }
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.createInvitation),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPermissionsDialog(BuildContext context, WidgetRef ref, CaregiverModel caregiver) {
    final selectedPermissions = List<CaregiverPermission>.from(caregiver.permissions);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Permissions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: CaregiverPermission.values.map((permission) {
              return CheckboxListTile(
                title: Text(permission.name.split(RegExp(r'(?=[A-Z])')).join(' ')),
                value: selectedPermissions.contains(permission),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedPermissions.add(permission);
                    } else {
                      selectedPermissions.remove(permission);
                    }
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final l10n = AppLocalizations.of(context)!;
                try {
                  final service = CaregiverService();
                  await service.updateCaregiverPermissions(
                    caregiverId: caregiver.id,
                    permissions: selectedPermissions,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.permissionsUpdated)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.errorGeneric}: $e')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveCaregiverDialog(BuildContext context, WidgetRef ref, CaregiverModel caregiver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Caregiver?'),
        content: Text('Remove ${caregiver.caregiverName}? They will no longer have access to your medication information.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final service = CaregiverService();
                await service.removeCaregiver(
                  userId: caregiver.userId,
                  caregiverId: caregiver.id,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Caregiver removed')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString()))),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
