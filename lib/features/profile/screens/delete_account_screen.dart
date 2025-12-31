import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _confirmDelete = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount(BuildContext context) async {
    if (!_confirmDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm account deletion')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Check if user signed in with OAuth (Google/Apple)
      final isOAuthUser = user.providerData.any(
        (provider) => provider.providerId == 'google.com' || provider.providerId == 'apple.com',
      );

      // Reauthenticate user (required before account deletion)
      if (!isOAuthUser) {
        // For email/password users, require password
        if (_passwordController.text.isEmpty) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your password')),
          );
          return;
        }

        if (user.email == null) {
          throw Exception('User email not found');
        }

        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _passwordController.text,
        );
        await user.reauthenticateWithCredential(credential);
      }
      // For OAuth users, Firebase will handle reauthentication automatically
      // when delete() is called if needed, or the session might be recent enough

      // extension 'delete-user-data' listens to this Auth event.
      // We do not need to call a manual Cloud Function.


      // Delete Firebase Auth account (must be last)
      await user.delete();

      if (!context.mounted) return;

      // Log out and navigate to login
      await ref.read(authProvider.notifier).signOut();
      
      if (!context.mounted) return;
      
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.accountDeletedSuccessfully),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } on FirebaseAuthException catch (e) {
      final l10n = AppLocalizations.of(context)!;
      String message = l10n.errorOccurredMessage;
      if (e.code == 'wrong-password') {
        message = l10n.incorrectPassword;
      } else if (e.code == 'requires-recent-login') {
        message = l10n.pleaseLogInAgainBeforeDeletingAccount;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.errorRed),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString())), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.warning(), color: AppColors.errorRed),
                      const SizedBox(width: 8),
                      Text(
                        'Warning: This action cannot be undone',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Deleting your account will permanently remove:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text('• All your medicines and reminders'),
                  const Text('• Your medication history and logs'),
                  const Text('• Your profile information and photos'),
                  const Text('• All app data and settings'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // User Info
            Text(
              'Account to delete:',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.borderLight(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Text(user?.email?.substring(0, 1).toUpperCase() ?? 'U')
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Password Confirmation (only for email/password users)
            Builder(
              builder: (context) {
                final user = FirebaseAuth.instance.currentUser;
                final isOAuthUser = user?.providerData.any(
                  (provider) => provider.providerId == 'google.com' || provider.providerId == 'apple.com',
                ) ?? false;

                if (isOAuthUser) {
                  // OAuth users don't need password
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight(context).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(AppIcons.info(), color: AppColors.primaryBlue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You signed in with ${user?.providerData.first.providerId == 'google.com' ? 'Google' : 'Apple'}. No password required.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your password to confirm:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(AppIcons.lock()),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? AppIcons.visibility() : AppIcons.visibilityOff(),
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Confirmation Checkbox
            CheckboxListTile(
              value: _confirmDelete,
              onChanged: (value) {
                setState(() => _confirmDelete = value ?? false);
              },
              title: const Text(
                'I understand that this action is permanent and cannot be undone',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.errorRed,
            ),
            const SizedBox(height: 24),

            // Delete Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _deleteAccount(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Delete My Account', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.borderLight(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
