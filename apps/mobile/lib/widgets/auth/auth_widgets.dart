import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme_tokens.dart';
import '../../services/localization_service.dart';
import '../../services/google_auth_service.dart';
import '../../state/app_state.dart';
import '../svc_snackbar.dart';
import '../brand_logo.dart';

String tr(String key, [Map<String, String>? vars]) => SvcLocalization.t(key, vars);

/// Maps FirebaseAuth error codes to a localized, user-facing message.
String authErrorMessage(String code) {
  switch (code) {
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return tr('auth.err.invalidCredentials');
    case 'invalid-email':
      return tr('auth.err.invalidEmail');
    case 'user-disabled':
      return tr('auth.err.disabled');
    case 'too-many-requests':
      return tr('auth.err.tooMany');
    case 'network-request-failed':
      return tr('auth.err.network');
    case 'email-already-in-use':
    case 'credential-already-in-use':
      return tr('auth.err.emailInUse');
    case 'account-exists-with-different-credential':
      return tr('auth.err.accountExistsDifferentCredential');
    case 'weak-password':
    case 'password-does-not-meet-requirements':
      return tr('auth.err.weakPassword');
    case 'operation-not-allowed':
      return tr('auth.err.unavailable');
    default:
      debugPrint('Unmapped auth error: $code');
      return tr('auth.err.generic');
  }
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return tr('auth.err.emailRequired');
  if (!_emailPattern.hasMatch(email)) return tr('auth.err.invalidEmail');
  return null;
}

/// Sign in with Apple is offered on iOS (required there when Google sign-in is offered).
bool get appleSignInAvailable => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

bool _isUserCancellation(FirebaseAuthException e) =>
    e.code == 'canceled' ||
    e.code == 'web-context-canceled' ||
    (e.message ?? '').contains('1001'); // ASAuthorizationError.canceled

/// Runs the Apple flow and shows the outcome. Returns true when signed in.
Future<bool> runAppleSignIn(BuildContext context, AppState appState) async {
  try {
    await appState.signInWithApple();
    if (!context.mounted) return true;
    final firstName = appState.currentUser?.name.split(' ').first ?? '';
    SvcSnackbar.success(context, firstName.isEmpty ? tr('auth.title.login') : tr('auth.welcome', {'name': firstName}));
    return true;
  } on FirebaseAuthException catch (e) {
    if (!_isUserCancellation(e) && context.mounted) SvcSnackbar.error(context, authErrorMessage(e.code));
  } catch (e) {
    debugPrint('Apple sign-in failed: $e');
    if (context.mounted) SvcSnackbar.error(context, tr('auth.err.generic'));
  }
  return false;
}

/// Runs the Google flow and shows the outcome. Returns true when signed in.
Future<bool> runGoogleSignIn(BuildContext context, AppState appState) async {
  if (!GoogleAuthService.isConfigured) {
    SvcSnackbar.info(context, tr('auth.googleUnavailable'));
    return false;
  }
  try {
    await appState.signInWithGoogle();
    if (!context.mounted) return true;
    final firstName = appState.currentUser?.name.split(' ').first ?? '';
    SvcSnackbar.success(context, firstName.isEmpty ? tr('auth.title.login') : tr('auth.welcome', {'name': firstName}));
    return true;
  } on GoogleSignInCancelled {
    return false;
  } on GoogleSignInNotConfigured {
    if (context.mounted) SvcSnackbar.info(context, tr('auth.googleUnavailable'));
  } on FirebaseAuthException catch (e) {
    if (context.mounted) SvcSnackbar.error(context, authErrorMessage(e.code));
  } catch (e) {
    debugPrint('Google sign-in failed: $e');
    if (context.mounted) SvcSnackbar.error(context, tr('auth.err.generic'));
  }
  return false;
}

/// Layout shared by the login, register and forgot-password screens (design A):
/// top bar, brand mark, title, the form, and a footer pinned to the bottom.
/// Rebuilds on language change, since pushed routes are not rebuilt by the app root.
class AuthScaffold extends StatelessWidget {
  final String titleKey;
  final String? subtitleKey;
  final WidgetBuilder bodyBuilder;
  final WidgetBuilder? footerBuilder;

  const AuthScaffold({
    super.key,
    required this.titleKey,
    this.subtitleKey,
    required this.bodyBuilder,
    this.footerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return ValueListenableBuilder<String>(
      valueListenable: SvcLocalization.languageNotifier,
      builder: (context, _, __) => Scaffold(
        backgroundColor: SvcColors.surface,
        body: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // The form lays out normally; only the footer fills the leftover space,
              // so it sits at the bottom on tall phones and scrolls on short ones.
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 48,
                            child: Row(
                              children: [
                                if (canPop)
                                  Transform.translate(
                                    offset: const Offset(-12, 0),
                                    child: IconButton(
                                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                                      icon: const Icon(Icons.chevron_left_rounded, size: 30, color: SvcColors.ink),
                                      onPressed: () => Navigator.of(context).maybePop(),
                                    ),
                                  ),
                                const Spacer(),
                                const LanguageSwitchButton(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: SvcBrandLogo.horizontal(size: 44, showSubtitle: false),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            tr(titleKey),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              color: SvcColors.ink,
                              height: 1.2,
                            ),
                          ),
                          if (subtitleKey != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              tr(subtitleKey!),
                              style: const TextStyle(fontSize: 15, color: SvcColors.muted, height: 1.45),
                            ),
                          ],
                          const SizedBox(height: 28),
                          bodyBuilder(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (footerBuilder != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                      child: footerBuilder!(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Listens itself: as a const child it is not rebuilt when the scaffold rebuilds.
    return ValueListenableBuilder<String>(
      valueListenable: SvcLocalization.languageNotifier,
      builder: (context, _, __) => OutlinedButton.icon(
        onPressed: SvcLocalization.toggleLanguage,
        icon: const Icon(Icons.translate_rounded, size: 16),
        label: Text(tr('auth.languageSwitch')),
        style: OutlinedButton.styleFrom(
          foregroundColor: SvcColors.ink,
          minimumSize: const Size(44, 36),
          tapTargetSize: MaterialTapTargetSize.padded,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          side: const BorderSide(color: SvcColors.border),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final String? prefixText;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool obscureText;
  final Widget? suffix;
  final Widget? labelAside;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.prefixText,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
    this.focusNode,
    this.obscureText = false,
    this.suffix,
    this.labelAside,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.labelAside != null ? 44 : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: SvcColors.ink),
                ),
              ),
              if (widget.labelAside != null) widget.labelAside!,
            ],
          ),
        ),
        SizedBox(height: widget.labelAside != null ? 0 : 6),
        Focus(
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: _focused
                  ? const [BoxShadow(color: SvcColors.primaryBorder, spreadRadius: 3, blurRadius: 0)]
                  : const [],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              obscureText: widget.obscureText,
              autocorrect: widget.autocorrect && !widget.obscureText,
              enableSuggestions: widget.autocorrect && !widget.obscureText,
              textCapitalization: widget.textCapitalization,
              inputFormatters: widget.inputFormatters,
              validator: widget.validator,
              onFieldSubmitted: widget.onSubmitted,
              style: const TextStyle(fontSize: 15.5, color: SvcColors.ink),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(color: SvcColors.subtle),
                errorMaxLines: 2,
                prefixText: widget.prefixText,
                prefixStyle: const TextStyle(fontSize: 16, color: SvcColors.ink, fontWeight: FontWeight.w600),
                suffixIcon: widget.suffix,
                filled: true,
                fillColor: SvcColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                border: border(SvcColors.borderStrong),
                enabledBorder: border(SvcColors.borderStrong),
                focusedBorder: border(SvcColors.primary, 1.5),
                errorBorder: border(SvcColors.danger),
                focusedErrorBorder: border(SvcColors.danger, 1.6),
              ),
            ),
          ),
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: 6),
          Text(widget.helper!, style: const TextStyle(fontSize: 13, color: SvcColors.muted, height: 1.4)),
        ],
      ],
    );
  }
}

/// Password field with a show/hide toggle.
class AuthPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool isNewPassword;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final Widget? labelAside;

  const AuthPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isNewPassword = false,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onSubmitted,
    this.focusNode,
    this.labelAside,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      focusNode: widget.focusNode,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: [widget.isNewPassword ? AutofillHints.newPassword : AutofillHints.password],
      validator: widget.validator,
      onSubmitted: widget.onSubmitted,
      labelAside: widget.labelAside,
      autocorrect: false,
      suffix: IconButton(
        tooltip: _obscure ? tr('auth.showPassword') : tr('auth.hidePassword'),
        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: SvcColors.muted, size: 20),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}

/// Brand-orange primary action.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SvcColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SvcColors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.1),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
            : Text(label),
      ),
    );
  }
}

/// White outlined button (Google, guest).
class AuthOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool loading;
  final Color textColor;
  final FontWeight fontWeight;

  const AuthOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.loading = false,
    this.textColor = SvcColors.ink,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: SvcColors.surface,
          side: const BorderSide(color: SvcColors.borderStrong, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: TextStyle(fontWeight: fontWeight, fontSize: 15),
        ),
        child: loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: SvcColors.primary))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 10)],
                  Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );
  }
}

const _googleLogoSvg = '''<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/></svg>''';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const GoogleSignInButton({super.key, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return AuthOutlinedButton(
      label: tr('auth.google'),
      onPressed: onPressed,
      loading: loading,
      leading: SvgPicture.string(_googleLogoSvg, width: 18, height: 18, excludeFromSemantics: true),
      fontWeight: FontWeight.w600,
    );
  }
}

/// Black "Continue with Apple" button per Apple's sign-in button guidelines.
class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const AppleSignInButton({super.key, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        child: loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.apple, size: 22),
                  const SizedBox(width: 8),
                  Flexible(child: Text(tr('auth.apple'), overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const Expanded(child: Divider(color: SvcColors.border, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(tr('auth.or'), style: const TextStyle(fontSize: 13, color: SvcColors.muted)),
          ),
          const Expanded(child: Divider(color: SvcColors.border, height: 1)),
        ],
      ),
    );
  }
}

/// Plain text link with a 44pt touch target.
class AuthLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const AuthLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize = 15,
    this.color = SvcColors.ink,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      child: Text(label, style: TextStyle(fontWeight: fontWeight, fontSize: fontSize)),
    );
  }
}

/// "Prompt text  Link" row at the bottom of an auth screen.
class AuthSwitchPrompt extends StatelessWidget {
  final String prompt;
  final String linkLabel;
  final VoidCallback onPressed;

  const AuthSwitchPrompt({super.key, required this.prompt, required this.linkLabel, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prompt, style: const TextStyle(color: SvcColors.muted, fontSize: 15)),
        const SizedBox(width: 4),
        AuthLinkButton(label: linkLabel, onPressed: onPressed),
      ],
    );
  }
}
