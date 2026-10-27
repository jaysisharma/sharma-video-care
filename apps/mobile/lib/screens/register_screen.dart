import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import '../widgets/auth/auth_widgets.dart';
import '../widgets/account/account_settings_sheets.dart';
import '../widgets/svc_snackbar.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final AppState appState;

  /// Tab to open when register is the root route.
  final int redirectIndex;

  /// When pushed from [LoginScreen], "Sign in" just goes back instead of stacking another login.
  final bool openedFromLogin;

  const RegisterScreen({
    super.key,
    required this.appState,
    this.redirectIndex = 0,
    this.openedFromLogin = false,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  late final TapGestureRecognizer _termsTap;

  bool _agreeTerms = false;
  bool _loading = false;
  bool _googleLoading = false;
  bool _appleLoading = false;

  bool get _busy => _loading || _googleLoading || _appleLoading;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = () => AccountSettingsSheets.showTermsDialog(context);
  }

  @override
  void dispose() {
    for (final c in [_nameController, _phoneController, _emailController, _passwordController, _confirmPasswordController]) {
      c.dispose();
    }
    for (final f in [_phoneFocus, _emailFocus, _passwordFocus, _confirmFocus]) {
      f.dispose();
    }
    _termsTap.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      SvcSnackbar.warning(context, tr('auth.err.terms'));
      return;
    }

    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      await widget.appState.signUp(
        name: _nameController.text.trim(),
        email: email,
        phone: _phoneController.text,
        password: _passwordController.text,
      );
      TextInput.finishAutofillContext();
      if (!mounted) return;
      SvcSnackbar.success(context, tr('auth.registerSuccess', {'email': email}));
      _finish();
    } on FirebaseAuthException catch (e) {
      if (mounted) SvcSnackbar.error(context, authErrorMessage(e.code, customMessage: e.message));
    } on FirebaseException catch (e) {
      final msg = (e.message != null && e.message!.isNotEmpty)
          ? '${e.code}: ${e.message}'
          : tr('auth.err.generic');
      if (mounted) SvcSnackbar.error(context, msg);
    } catch (e) {
      debugPrint('Sign up failed: $e');
      final errStr = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (mounted) SvcSnackbar.error(context, errStr.isNotEmpty ? errStr : tr('auth.err.generic'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _finish() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(true);
    } else {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(appState: widget.appState, initialIndex: widget.redirectIndex),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _google() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _googleLoading = true);
    final signedIn = await runGoogleSignIn(context, widget.appState);
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (signedIn) _finish();
  }

  Future<void> _apple() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _appleLoading = true);
    final signedIn = await runAppleSignIn(context, widget.appState);
    if (!mounted) return;
    setState(() => _appleLoading = false);
    if (signedIn) _finish();
  }

  void _goToSignIn() {
    if (widget.openedFromLogin) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen(appState: widget.appState, redirectIndex: widget.redirectIndex)),
      );
    }
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.length < 8 || !RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return tr('auth.err.weakPassword');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      titleKey: 'auth.title.register',
      subtitleKey: 'auth.subtitle.register',
      bodyBuilder: (context) => AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                label: tr('auth.name'),
                controller: _nameController,
                hint: tr('auth.namePlaceholder'),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                validator: (v) => (v == null || v.trim().length < 2) ? tr('auth.err.name') : null,
                onSubmitted: (_) => _phoneFocus.requestFocus(),
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: tr('auth.phone'),
                controller: _phoneController,
                focusNode: _phoneFocus,
                hint: '98XXXXXXXX',
                helper: tr('auth.phoneHint'),
                prefixText: '+977  ',
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                autocorrect: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (v) => FirestoreService.isValidNepalMobile(v ?? '') ? null : tr('auth.err.phone'),
                onSubmitted: (_) => _emailFocus.requestFocus(),
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: tr('auth.email'),
                controller: _emailController,
                focusNode: _emailFocus,
                hint: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                validator: validateEmail,
                onSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: 14),
              AuthPasswordField(
                label: tr('auth.password'),
                controller: _passwordController,
                focusNode: _passwordFocus,
                hint: tr('auth.passwordPlaceholder'),
                isNewPassword: true,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
                onSubmitted: (_) => _confirmFocus.requestFocus(),
              ),
              const SizedBox(height: 14),
              AuthPasswordField(
                label: tr('auth.confirmPassword'),
                controller: _confirmPasswordController,
                focusNode: _confirmFocus,
                isNewPassword: true,
                validator: (v) => v != _passwordController.text ? tr('auth.err.mismatch') : null,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeTerms,
                        activeColor: SvcColors.primary,
                        onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(fontSize: 13, color: SvcColors.ink, height: 1.45),
                              children: [
                                TextSpan(text: tr('auth.agreePrefix')),
                                TextSpan(
                                  text: tr('auth.terms'),
                                  recognizer: _termsTap,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: SvcColors.primary,
                                    decorationThickness: 2,
                                  ),
                                ),
                                TextSpan(text: tr('auth.agreeSuffix')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AuthPrimaryButton(label: tr('auth.createAccount'), loading: _loading, onPressed: _busy ? null : _submit),
              const AuthOrDivider(),
              if (appleSignInAvailable) ...[
                AppleSignInButton(onPressed: _busy ? null : _apple, loading: _appleLoading),
                const SizedBox(height: 10),
              ],
              GoogleSignInButton(onPressed: _busy ? null : _google, loading: _googleLoading),
            ],
          ),
        ),
      ),
      footerBuilder: (context) => AuthSwitchPrompt(
        prompt: tr('auth.haveAccount'),
        linkLabel: tr('auth.signIn'),
        onPressed: _goToSignIn,
      ),
    );
  }
}
