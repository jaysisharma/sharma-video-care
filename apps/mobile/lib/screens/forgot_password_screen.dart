import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../widgets/auth/auth_widgets.dart';
import '../widgets/svc_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AppState appState;

  const ForgotPasswordScreen({super.key, required this.appState});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showSent() {
    setState(() => _sent = true);
    SvcSnackbar.success(context, tr('auth.resetSentToast'));
  }

  Future<void> _submit() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await widget.appState.resetPassword(_emailController.text.trim());
      if (mounted) _showSent();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Never reveal whether an account exists for this email.
      if (e.code == 'user-not-found') {
        _showSent();
      } else {
        SvcSnackbar.error(context, authErrorMessage(e.code));
      }
    } catch (e) {
      debugPrint('Password reset failed: $e');
      if (mounted) SvcSnackbar.error(context, tr('auth.err.generic'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titleKey: 'auth.title.forgot',
      subtitleKey: _sent ? null : 'auth.subtitle.forgot',
      bodyBuilder: (context) => _sent ? _buildSent() : _buildForm(),
      footerBuilder: _sent
          ? null
          : (context) => AuthSwitchPrompt(
                prompt: tr('auth.rememberPassword'),
                linkLabel: tr('auth.signIn'),
                onPressed: () => Navigator.of(context).pop(),
              ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: tr('auth.email'),
            controller: _emailController,
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            validator: validateEmail,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(label: tr('auth.sendReset'), loading: _loading, onPressed: _submit),
        ],
      ),
    );
  }

  Widget _buildSent() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(color: Color(0xFFE3F4EA), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined, color: SvcColors.success, size: 28),
        ),
        const SizedBox(height: 14),
        Text(
          tr('auth.resetSentTitle'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: SvcColors.ink),
        ),
        const SizedBox(height: 6),
        Text(
          tr('auth.resetSentBody', {'email': _emailController.text.trim()}),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: SvcColors.inkSecondary, height: 1.45),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: AuthPrimaryButton(label: tr('auth.backToLogin'), onPressed: () => Navigator.of(context).pop()),
        ),
      ],
    );
  }
}
