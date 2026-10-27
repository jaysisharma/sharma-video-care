import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharma_video_care_mobile/screens/forgot_password_screen.dart';
import 'package:sharma_video_care_mobile/screens/login_screen.dart';
import 'package:sharma_video_care_mobile/screens/register_screen.dart';
import 'package:sharma_video_care_mobile/services/firestore_service.dart';
import 'package:sharma_video_care_mobile/services/localization_service.dart';
import 'package:sharma_video_care_mobile/state/app_state.dart';
import 'package:sharma_video_care_mobile/widgets/auth/auth_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SvcLocalization.setLanguage('en');
  });

  group('Nepal phone numbers', () {
    test('normalizes common input formats to +977-98XXXXXXXX', () {
      expect(FirestoreService.normalizeNepalPhone('9801234567'), '+977-9801234567');
      expect(FirestoreService.normalizeNepalPhone('+977 980-123-4567'), '+977-9801234567');
      expect(FirestoreService.normalizeNepalPhone('977-9801234567'), '+977-9801234567');
    });

    test('accepts 96/97/98 mobiles and rejects others', () {
      expect(FirestoreService.isValidNepalMobile('9612345678'), isTrue);
      expect(FirestoreService.isValidNepalMobile('9741234567'), isTrue);
      expect(FirestoreService.isValidNepalMobile('+977-9801234567'), isTrue);
      expect(FirestoreService.isValidNepalMobile('9512345678'), isFalse);
      expect(FirestoreService.isValidNepalMobile('980123456'), isFalse);
      expect(FirestoreService.isValidNepalMobile(''), isFalse);
    });
  });

  group('Localization', () {
    test('fills placeholders in both languages', () async {
      expect(SvcLocalization.t('auth.welcome', {'name': 'Ramesh'}), 'Welcome back, Ramesh!');
      await SvcLocalization.setLanguage('ne');
      expect(SvcLocalization.t('auth.welcome', {'name': 'Ramesh'}), 'फेरि स्वागत छ, Ramesh!');
    });

    test('every auth key has a Nepali translation', () async {
      const keys = [
        'auth.title.login', 'auth.email', 'auth.password', 'auth.forgot', 'auth.signIn',
        'auth.createAccount', 'auth.continueGuest', 'auth.title.register', 'auth.phone',
        'auth.terms', 'auth.title.forgot', 'auth.sendReset', 'auth.err.invalidCredentials',
        'auth.err.phone', 'auth.err.weakPassword', 'auth.err.mismatch', 'auth.err.network',
      ];
      for (final key in keys) {
        await SvcLocalization.setLanguage('en');
        final en = SvcLocalization.t(key);
        await SvcLocalization.setLanguage('ne');
        final ne = SvcLocalization.t(key);
        expect(en, isNot(key), reason: '$key missing');
        expect(ne, isNot(en), reason: '$key not translated');
      }
    });
  });

  group('Auth screens', () {
    Future<void> pump(WidgetTester tester, Widget screen) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.6;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: screen));
      await tester.pump();
    }

    testWidgets('login validates empty fields without calling Firebase', (tester) async {
      await pump(tester, LoginScreen(appState: AppState()));
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('login rejects a malformed email', (tester) async {
      await pump(tester, LoginScreen(appState: AppState()));
      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });

    testWidgets('language switch translates the login screen in place', (tester) async {
      await pump(tester, LoginScreen(appState: AppState()));
      expect(find.text('Welcome back'), findsOneWidget);
      await tester.tap(find.text('नेपाली'));
      await tester.pumpAndSettle();
      expect(find.text('फेरि स्वागत छ'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('links and buttons have at least 44pt touch targets', (tester) async {
      await pump(tester, LoginScreen(appState: AppState()));
      for (final label in ['Forgot password?', 'Create an account', 'Sign in']) {
        final button = find.ancestor(of: find.text(label), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
        expect(tester.getSize(button.first).height, greaterThanOrEqualTo(44), reason: label);
      }
    });

    testWidgets('login shows Google and guest options in design A order', (tester) async {
      await pump(tester, LoginScreen(appState: AppState()));
      final signIn = tester.getTopLeft(find.text('Sign in')).dy;
      final google = tester.getTopLeft(find.text('Continue with Google')).dy;
      final guest = tester.getTopLeft(find.text('Continue as guest')).dy;
      expect(find.text('QuickySewa'.toUpperCase()), findsOneWidget); // real brand logo
      expect(signIn < google && google < guest, isTrue);
      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('Google button explains instead of crashing while not configured', (tester) async {
      await pump(tester, LoginScreen(appState: AppState()));
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      await tester.pump();
      expect(find.text("Google sign-in isn't available yet. Please use email for now."), findsOneWidget);
    });

    testWidgets('fields declare autofill hints for password managers', (tester) async {
      await pump(tester, LoginScreen(appState: AppState()));
      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields[0].autofillHints, contains(AutofillHints.email));
      expect(fields[1].autofillHints, contains(AutofillHints.password));
      expect(find.byType(AutofillGroup), findsOneWidget);
    });

    testWidgets('register enforces phone, password strength, match and terms', (tester) async {
      await pump(tester, RegisterScreen(appState: AppState()));
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ramesh Sah');
      await tester.enterText(fields.at(1), '12345');
      await tester.enterText(fields.at(2), 'ramesh@example.com');
      await tester.enterText(fields.at(3), 'short');
      await tester.enterText(fields.at(4), 'different1');
      await tester.ensureVisible(find.text('Create an account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create an account'));
      await tester.pump();
      expect(find.text('Enter a valid 10-digit mobile number (98XXXXXXXX).'), findsOneWidget);
      expect(find.text('Use at least 8 characters with letters and numbers.'), findsOneWidget);
      expect(find.text('Passwords do not match.'), findsOneWidget);

      // Valid form but terms unchecked -> warning snackbar, no Firebase call.
      await tester.enterText(fields.at(1), '9801234567');
      await tester.enterText(fields.at(3), 'goodpass1');
      await tester.enterText(fields.at(4), 'goodpass1');
      await tester.ensureVisible(find.text('Create an account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create an account'));
      await tester.pump();
      expect(find.text('Please accept the Terms of Service to continue.'), findsOneWidget);
    });

    testWidgets('phone field accepts digits only, max 10', (tester) async {
      await pump(tester, RegisterScreen(appState: AppState()));
      final phone = find.byType(TextFormField).at(1);
      await tester.enterText(phone, '98-0123 45678');
      final value = tester.widget<TextField>(find.descendant(of: phone, matching: find.byType(TextField))).controller!.text;
      expect(value, '9801234567');
    });

    testWidgets('forgot password validates email', (tester) async {
      await pump(tester, ForgotPasswordScreen(appState: AppState()));
      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      expect(find.text('Please enter your email address.'), findsOneWidget);
    });
  });

  group('authErrorMessage normalization', () {
    test('normalizes legacy and uppercase Firebase error codes', () {
      expect(authErrorMessage('ERROR_WRONG_PASSWORD'), 'Email or password is incorrect.');
      expect(authErrorMessage('INVALID_LOGIN_CREDENTIALS'), 'Email or password is incorrect.');
      expect(authErrorMessage('ERROR_EMAIL_ALREADY_IN_USE'), 'An account with this email already exists. Please sign in.');
      expect(authErrorMessage('EMAIL_EXISTS'), 'An account with this email already exists. Please sign in.');
      expect(authErrorMessage('ERROR_NETWORK_REQUEST_FAILED'), 'No internet connection. Please check and try again.');
      expect(authErrorMessage('ERROR_OPERATION_NOT_ALLOWED'), 'Sign-up is temporarily unavailable. Please contact support.');
    });

    test('falls back to custom message when code is unmapped', () {
      expect(authErrorMessage('unknown_code', customMessage: 'Custom reason here'), 'Custom reason here');
      expect(authErrorMessage('unknown_code'), 'Something went wrong. Please try again.');
    });
  });
}
