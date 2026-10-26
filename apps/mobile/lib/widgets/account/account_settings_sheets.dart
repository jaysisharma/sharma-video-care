import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../services/localization_service.dart';
import '../../screens/login_screen.dart';
import '../../services/google_auth_service.dart';
import '../svc_snackbar.dart';

class AccountSettingsSheets {
  static Widget buildSheetHandle() {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  static void showAuthRequiredPrompt(BuildContext context, AppState appState, String reason) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildSheetHandle(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: Color(0xFFF97316), size: 30),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Sign In Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please sign in to your QuickySewa account to $reason.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(appState: appState, redirectIndex: 4),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Sign In to Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showLogoutConfirmSheet({
    required BuildContext context,
    required AppState appState,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildSheetHandle(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Sign Out of Video Care?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You will need to sign in again to view your live repair quotes and nationwide order shipments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          await appState.signOut();
                          if (context.mounted) {
                            SvcSnackbar.show(context, 'Signed out successfully', type: SnackType.success);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => LoginScreen(appState: appState),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void openPersonalInfoModal({
    required BuildContext context,
    required UserModel? user,
    required AppState appState,
    required void Function(BuildContext, String) showAuthRequiredPrompt,
  }) {
    if (user == null) {
      showAuthRequiredPrompt(context, 'view and update your personal information');
      return;
    }

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final emailController = TextEditingController(text: user.email);
    bool isSaving = false;
    String? modalError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSheetHandle(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, color: Color(0xFFF97316)),
                      const SizedBox(width: 8),
                      const Text(
                        'Personal Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isSaving ? null : () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  if (modalError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        modalError!,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+977 98XXXXXXXX',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                      helperText: 'Email is linked to your Firebase credentials and cannot be edited directly',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              final phone = phoneController.text.trim();
                              if (name.isEmpty) {
                                setSheetState(() => modalError = 'Please enter your full name');
                                return;
                              }
                              setSheetState(() {
                                isSaving = true;
                                modalError = null;
                              });

                              try {
                                await appState.updateUserProfile(
                                  name: name,
                                  phone: phone,
                                );
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                                if (context.mounted) {
                                  SvcSnackbar.show(context, 'Profile updated successfully.', type: SnackType.success);
                                }
                              } catch (e) {
                                setSheetState(() {
                                  isSaving = false;
                                  modalError = 'Update failed: $e';
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void openNotificationsModal({
    required BuildContext context,
    required bool orderNotifications,
    required bool repairNotifications,
    required bool promoNotifications,
    required void Function(bool orders, bool repairs, bool promos) onChanged,
  }) {
    bool orders = orderNotifications;
    bool repairs = repairNotifications;
    bool promos = promoNotifications;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildSheetHandle(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.notifications_none_outlined, color: Color(0xFFF97316)),
                        const SizedBox(width: 8),
                        const Text(
                          'Notification Preferences',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFFF97316),
                      title: const Text('Order Status Updates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Courier tracking and dispatch notifications', style: TextStyle(fontSize: 12)),
                      value: orders,
                      onChanged: (val) {
                        setSheetState(() => orders = val);
                        onChanged(orders, repairs, promos);
                      },
                    ),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFFF97316),
                      title: const Text('Service & Repair Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Diagnostic quotes and technician updates', style: TextStyle(fontSize: 12)),
                      value: repairs,
                      onChanged: (val) {
                        setSheetState(() => repairs = val);
                        onChanged(orders, repairs, promos);
                      },
                    ),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFFF97316),
                      title: const Text('Gear Drops & Promotions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Pre-owned inventory and cinema discounts', style: TextStyle(fontSize: 12)),
                      value: promos,
                      onChanged: (val) {
                        setSheetState(() => promos = val);
                        onChanged(orders, repairs, promos);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void openPrivacyModal({
    required BuildContext context,
    required UserModel? user,
    required AppState appState,
    required void Function(BuildContext, String) showAuthRequiredPrompt,
  }) {
    if (user == null) {
      showAuthRequiredPrompt(context, 'access your privacy and security settings');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSheetHandle(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFFF97316)),
                    const SizedBox(width: 8),
                    const Text(
                      'Privacy & Security',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
                  title: const Text('Change Account Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('Send password recovery email to ${user.email}', style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (dlgContext) => AlertDialog(
                        title: const Text('Reset Password?'),
                        content: Text(
                          'We will dispatch a secure password reset link to your registered email (${user.email}).',
                          style: const TextStyle(fontSize: 13),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dlgContext),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(dlgContext);
                              try {
                                await appState.resetPassword(user.email);
                                if (context.mounted) {
                                  SvcSnackbar.show(context, 'Password reset link sent to ${user.email}.', type: SnackType.success);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  SvcSnackbar.show(context, 'Couldn\'t send the reset email. Please try again.', type: SnackType.error);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Send Reset Link'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (!appState.isEmailVerified)
                  ListTile(
                    leading: const Icon(Icons.mark_email_unread_outlined, color: Color(0xFFF97316)),
                    title: const Text('Verify Your Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('Resend verification link to ${user.email}', style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await appState.resendVerificationEmail();
                        if (context.mounted) {
                          SvcSnackbar.show(context, 'Verification email sent to ${user.email}.', type: SnackType.success);
                        }
                      } catch (_) {
                        if (context.mounted) {
                          SvcSnackbar.show(context, 'Could not send verification email. Please try again later.', type: SnackType.error);
                        }
                      }
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Color(0xFF64748B)),
                  title: const Text('Data Privacy & Terms of Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Read service agreement and data protection policies', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                    showTermsDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: Color(0xFFEF4444)),
                  title: const Text('Delete Account',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                  subtitle: const Text('Permanently remove your login and profile', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDeleteAccountDialog(context: context, appState: appState);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showDeleteAccountDialog({
    required BuildContext context,
    required AppState appState,
  }) {
    final passwordCtrl = TextEditingController();
    // Google-only accounts have no password; they confirm by choosing their Google account.
    final usesPassword = appState.hasPasswordSignIn;
    bool deleting = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgContext) => StatefulBuilder(
        builder: (dlgContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Account?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usesPassword
                    ? 'This permanently deletes your login and profile. Order and repair records are kept for warranty and accounting. Enter your password to confirm.'
                    : 'This permanently deletes your login and profile. Order and repair records are kept for warranty and accounting. Sign in again to confirm.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              if (!usesPassword && error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
              ],
              if (usesPassword) const SizedBox(height: 14),
              if (usesPassword) TextField(
                controller: passwordCtrl,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: 'Current password',
                  errorText: error,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: deleting ? null : () => Navigator.pop(dlgContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: deleting
                  ? null
                  : () async {
                      if (usesPassword && passwordCtrl.text.isEmpty) return;
                      setDialogState(() {
                        deleting = true;
                        error = null;
                      });
                      try {
                        await appState.deleteAccount(currentPassword: usesPassword ? passwordCtrl.text : null);
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginScreen(appState: appState)),
                          (route) => false,
                        );
                        SvcSnackbar.show(context, 'Your account has been deleted.', type: SnackType.success);
                      } on GoogleSignInCancelled {
                        setDialogState(() => deleting = false);
                      } on FirebaseAuthException catch (e) {
                        setDialogState(() {
                          deleting = false;
                          error = (e.code == 'wrong-password' || e.code == 'invalid-credential')
                              ? 'Incorrect password'
                              : 'Could not delete account. Please try again.';
                        });
                      } catch (_) {
                        setDialogState(() {
                          deleting = false;
                          error = 'Could not delete account. Please try again.';
                        });
                      }
                    },
              child: deleting
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(usesPassword ? 'Delete' : 'Confirm and delete'),
            ),
          ],
        ),
      ),
    );
  }

  static void showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Color(0xFFF97316)),
            SizedBox(width: 8),
            Text('Terms & Data Policy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QuickySewa Service Agreement',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
              ),
              SizedBox(height: 8),
              Text(
                '1. Diagnostic Inspections: All physical assessments at our Janakpur workshop are conducted with Rs. 0 inspection fee.\n\n'
                '2. Nationwide Insured Transit: Equipment sent via our Nepal courier network is handled with verified custody tracking.\n\n'
                '3. Genuine Components: All sensor cleanings, optical alignments, and motherboard repairs use manufacturer-grade parts with official warranty coverage.\n\n'
                '4. Data Privacy: Your account and equipment records are securely encrypted and protected in accordance with privacy regulations.',
                style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dlgContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void openAppSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSheetHandle(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.settings_outlined, color: Color(0xFFF97316)),
                    const SizedBox(width: 8),
                    const Text(
                      'App Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.language_outlined, color: Color(0xFF64748B)),
                  title: const Text('Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(SvcLocalization.isNepali ? 'Nepali (नेपाली)' : 'English (Nepal)'),
                  trailing: const Icon(Icons.swap_horiz, size: 20, color: Color(0xFFF97316)),
                  onTap: () {
                    SvcLocalization.toggleLanguage();
                    Navigator.pop(ctx);
                    SvcSnackbar.show(context, SvcLocalization.isNepali ? 'भाषा नेपालीमा परिवर्तन गरियो' : 'Language set to English', type: SnackType.info);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: Color(0xFF64748B)),
                  title: const Text('Appearance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Light Clean Optics Mode'),
                  trailing: const Icon(Icons.check, size: 18, color: Color(0xFF16A34A)),
                  onTap: () {
                    Navigator.pop(ctx);
                    SvcSnackbar.show(context, 'Optics Pro clean light mode is active.', type: SnackType.info);
                  },
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Color(0xFF64748B)),
                  title: Text('App Version', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('QuickySewa v1.0.0 (Build 100)'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
