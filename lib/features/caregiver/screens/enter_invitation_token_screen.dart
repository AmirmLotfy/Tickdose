import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/services/caregiver_sharing_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';
import '../../auth/widgets/auth_button.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

/// Screen for manually entering invitation token
class EnterInvitationTokenScreen extends ConsumerStatefulWidget {
  const EnterInvitationTokenScreen({super.key});

  @override
  ConsumerState<EnterInvitationTokenScreen> createState() => _EnterInvitationTokenScreenState();
}

class _EnterInvitationTokenScreenState extends ConsumerState<EnterInvitationTokenScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final CaregiverSharingService _sharingService = CaregiverSharingService();
  bool _isLoading = false;
  bool _isValidating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _validateToken() async {
    final token = _tokenController.text.trim();
    
    if (token.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.enterInvitationCodePrompt;
      });
      return;
    }

    // Basic token format validation (64 hex characters)
    if (token.length != 64 || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(token)) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.invalidInvitationFormat;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isValidating = true;
    });

    try {
      // Check if invitation exists and is valid
      final invitation = await _sharingService.getInvitation(token);
      
      if (invitation == null) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.invitationNotFound;
          _isValidating = false;
        });
        return;
      }

      final used = invitation['used'] as bool? ?? false;
      if (used) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.invitationUsed;
          _isValidating = false;
        });
        return;
      }

      final expiresAt = (invitation['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.invitationExpired;
          _isValidating = false;
        });
        return;
      }

      // Token is valid, navigate to invitation acceptance screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          Routes.caregiverInvitation,
          arguments: {'token': token},
        );
      }
    } catch (e) {
      Logger.error('Error validating token: $e', tag: 'EnterInvitationToken');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.invitationError;
        _isValidating = false;
      });
    }
  }

  Future<void> _acceptTokenDirectly() async {
    final token = _tokenController.text.trim();
    final user = ref.read(authStateProvider).value;
    
    if (user == null) {
      // User not logged in, show message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseLogInToAccept),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accepted = await _sharingService.acceptInvitation(
        token: token,
        caregiverUserId: user.uid,
      );

      if (mounted) {
        if (accepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invitationAcceptedSuccess),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.invitationFailed;
          });
        }
      }
    } catch (e) {
      Logger.error('Error accepting invitation: $e', tag: 'EnterInvitationToken');
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.invitationError;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.acceptInvitationTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.invitationCodeInputLabel,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.invitationCodeInputDescription,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Token input field
          TextField(
            controller: _tokenController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.invitationCodeLabel,
              hintText: AppLocalizations.of(context)!.enterInvitationCodePrompt,
              prefixIcon: const Icon(Icons.vpn_key),
              errorText: _errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            maxLength: 64,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
              return Text(
                '$currentLength / $maxLength',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              );
            },
            onChanged: (_) {
              // Clear error when user types
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
          ),
          const SizedBox(height: 24),

          // Action buttons
          if (_isValidating)
            const Center(child: CircularProgressIndicator())
          else
            AuthButton(
              text: user != null ? AppLocalizations.of(context)!.acceptInvitationButton : AppLocalizations.of(context)!.validateCodeButton,
              onPressed: _isLoading ? null : (user != null ? _acceptTokenDirectly : _validateToken),
              isLoading: _isLoading,
            ),

          if (user == null) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.loginRequiredNote,
              style: const TextStyle(
                color: AppColors.warningOrange,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 32),

          // Instructions
          Card(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.howToFindCodeTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionItem(
                    context,
                    AppLocalizations.of(context)!.howToFindCodeStep1,
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem(
                    context,
                    AppLocalizations.of(context)!.howToFindCodeStep2,
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem(
                    context,
                    AppLocalizations.of(context)!.howToFindCodeStep3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}
