import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../main.dart';
import '../widgets/auth/auth_widgets.dart';
import '../widgets/svc_snackbar.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final AppState appState;

  /// Tab to open when login is the root route (e.g. after signing out).
  /// When login was pushed on top of another screen it simply pops back there.
  final int redirectIndex;

  const LoginScreen({
    super.key,
    required this.appState,
    this.redirectIndex = 0,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _loading = false;
  bool _googleLoading = false;
  bool _appleLoading = false;

  bool get _busy => _loading || _googleLoading || _appleLoading;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Returns to the screen that asked for login, or opens the app if login is the root.
  void _leave({bool signedIn = false}) {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(signedIn);
    } else {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(appState: widget.appState, initialIndex: widget.redirectIndex),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await widget.appState.signIn(_emailController.text.trim(), _passwordController.text);
      TextInput.finishAutofillContext(); // lets the OS offer to save the password
      if (!mounted) return;
      final firstName = widget.appState.currentUser?.name.split(' ').first ?? '';
      SvcSnackbar.success(context, firstName.isEmpty ? tr('auth.title.login') : tr('auth.welcome', {'name': firstName}));
      _leave(signedIn: true);
    } on FirebaseAuthException catch (e) {
      if (mounted) SvcSnackbar.error(context, authErrorMessage(e.code));
    } catch (e) {
      debugPrint('Sign in failed: $e');
      if (mounted) SvcSnackbar.error(context, tr('auth.err.generic'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _googleLoading = true);
    final signedIn = await runGoogleSignIn(context, widget.appState);
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (signedIn) _leave(signedIn: true);
  }

  Future<void> _apple() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _appleLoading = true);
    final signedIn = await runAppleSignIn(context, widget.appState);
    if (!mounted) return;
    setState(() => _appleLoading = false);
    if (signedIn) _leave(signedIn: true);
  }

  Future<void> _openRegister() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RegisterScreen(appState: widget.appState, openedFromLogin: true)),
    );
    if (created == true) _leave(signedIn: true);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titleKey: 'auth.title.login',
      subtitleKey: 'auth.subtitle.login',
      bodyBuilder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthTextField(
                    label: tr('auth.email'),
                    controller: _emailController,
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email, AutofillHints.username],
                    autocorrect: false,
                    validator: validateEmail,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 14),
                  AuthPasswordField(
                    label: tr('auth.password'),
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    validator: (v) => (v == null || v.isEmpty) ? tr('auth.err.passwordRequired') : null,
                    onSubmitted: (_) => _submit(),
                    labelAside: AuthLinkButton(
                      label: tr('auth.forgot'),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: SvcColors.inkSecondary,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ForgotPasswordScreen(appState: widget.appState)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  AuthPrimaryButton(label: tr('auth.signIn'), loading: _loading, onPressed: _busy ? null : _submit),
                ],
              ),
            ),
          ),
          const AuthOrDivider(),
          if (appleSignInAvailable) ...[
            AppleSignInButton(onPressed: _busy ? null : _apple, loading: _appleLoading),
            const SizedBox(height: 10),
          ],
          GoogleSignInButton(onPressed: _busy ? null : _google, loading: _googleLoading),
          const SizedBox(height: 8),
          Center(
            child: AuthLinkButton(
              label: tr('auth.guestButton'),
              onPressed: _busy ? null : _leave,
              color: SvcColors.inkSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      footerBuilder: (context) => AuthSwitchPrompt(
        prompt: tr('auth.noAccount'),
        linkLabel: tr('auth.createAccount'),
        onPressed: _openRegister,
      ),
    );
  }
}
