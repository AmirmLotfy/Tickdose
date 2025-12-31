import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/services/caregiver_sharing_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';
import '../../auth/widgets/auth_button.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class CaregiverInvitationScreen extends ConsumerStatefulWidget {
  final String invitationToken;

  const CaregiverInvitationScreen({
    super.key,
    required this.invitationToken,
  });

  @override
  ConsumerState<CaregiverInvitationScreen> createState() => _CaregiverInvitationScreenState();
}

class _CaregiverInvitationScreenState extends ConsumerState<CaregiverInvitationScreen> {
  final CaregiverSharingService _sharingService = CaregiverSharingService();
  Map<String, dynamic>? _invitationData;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadInvitation();
  }

  Future<void> _loadInvitation() async {
    try {
      final data = await _sharingService.getInvitation(widget.invitationToken);
      setState(() {
        _invitationData = data;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Error loading invitation: $e', tag: 'CaregiverInvitation');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptInvitation() async {
    final user = ref.read(authStateProvider).value;
    
    if (user == null) {
      // User not logged in, redirect to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseLogInToAccept),
            backgroundColor: AppColors.warningOrange,
          ),
        );
        // Store invitation token and navigate to login
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
          (route) => false,
          arguments: {'invitationToken': widget.invitationToken},
        );
      }
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final accepted = await _sharingService.acceptInvitation(
        token: widget.invitationToken,
        caregiverUserId: user.uid,
      );

      if (mounted) {
        if (accepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invitationAcceptedView),
              backgroundColor: AppColors.successGreen,
            ),
          );
          // Navigate to caregiver dashboard or home
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invitationFailed),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      Logger.error('Error accepting invitation: $e', tag: 'CaregiverInvitation');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorLabel(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_invitationData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.invalidInvitationTitle)),
        body: Center(child: Text(AppLocalizations.of(context)!.invalidInvitationMessage)),
      );
    }

    final used = _invitationData!['used'] as bool? ?? false;
    if (used) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.invitationUsedTitle)),
        body: Center(child: Text(AppLocalizations.of(context)!.invitationUsedMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.invitationTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(
            Icons.family_restroom,
            size: 80,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.invitedTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.invitedMessage,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Permissions overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.permissionsTitle,
                    style: AppTextStyles.h3(context),
                  ),
                  const SizedBox(height: 12),
                  ...((_invitationData!['permissions'] as List<dynamic>?) ?? []).map((perm) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.successGreen, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              perm.toString().split('.').last.split(RegExp(r'(?=[A-Z])')).join(' '),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          AuthButton(
            text: _isProcessing ? 'Processing...' : AppLocalizations.of(context)!.acceptInvitationButton,
            onPressed: _isProcessing ? null : _acceptInvitation,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: Text(AppLocalizations.of(context)!.declineButton),
          ),
        ],
      ),
    );
  }
}
