import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'theme_tokens.dart';
import 'state/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/service_request_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/account_screen.dart';
import 'screens/technician_screen.dart';
import 'screens/used_screen.dart';
import 'screens/splash_screen.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Release builds otherwise draw a failed widget as a plain grey box. Debug keeps
  // Flutter's red error screen; the details go to Crashlytics either way.
  if (kReleaseMode) {
    ErrorWidget.builder = (_) => const _BrokenWidgetPlaceholder();
  }

  if (await _initFirebase()) {
    await _startApp();
  } else {
    // Auth, products, orders and chat all depend on Firebase; without it every
    // screen would fail, so offer a retry instead.
    runApp(const _StartupErrorApp());
  }
}

/// Startup errors caught before Crashlytics is ready; reported once it is.
final List<(Object, StackTrace)> _startupErrors = [];

/// Firebase setup is local (no network), so a failure here is a config or plugin
/// problem. Tries the generated options first, then the native config from
/// google-services.json. Safe to call again after a failed attempt.
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return true;
  } on FirebaseException catch (e, stack) {
    if (e.code == 'duplicate-app') return true;
    _startupErrors.add((e, stack));
  } catch (e, stack) {
    _startupErrors.add((e, stack));
  }
  debugPrint('Firebase init with generated options failed: ${_startupErrors.last.$1}');

  try {
    await Firebase.initializeApp();
    return true;
  } catch (e, stack) {
    debugPrint('Firebase init with native config failed: $e\n$stack');
    return false;
  }
}

/// Runs once Firebase is up: error reporting, saved language and session, then the app.
Future<void> _startApp() async {
  _setUpCrashReporting();
  for (final (error, stack) in _startupErrors) {
    // Init recovered via the fallback, which points at a firebase_options.dart /
    // google-services.json mismatch worth fixing.
    FirebaseCrashlytics.instance.recordError(error, stack, reason: 'Firebase init (recovered)');
  }
  _startupErrors.clear();

  try {
    await SvcLocalization.init();
  } catch (e) {
    debugPrint('Localization initialization notice: $e');
  }

  final appState = AppState();
  try {
    await appState.loadSession();
  } catch (e) {
    debugPrint('Session load notice: $e');
  }

  runApp(SharmaVideoCareApp(appState: appState));
}

/// Sends Flutter build/layout errors and uncaught async errors to Crashlytics, so
/// release-build failures show up in the Firebase console with stack traces.
void _setUpCrashReporting() {
  final crashlytics = FirebaseCrashlytics.instance;
  crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    crashlytics.recordFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };
}

/// Shown in place of a widget that failed to build (release only). Scales down to
/// fit anything from a product card to a full page, and never shows error text.
class _BrokenWidgetPlaceholder extends StatelessWidget {
  const _BrokenWidgetPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: SvcColors.canvas,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 28, color: SvcColors.muted),
                  const SizedBox(height: 6),
                  Text(
                    SvcLocalization.isNepali ? 'यो भाग देखाउन सकिएन' : "Couldn't show this section",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: SvcColors.muted,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupErrorApp extends StatefulWidget {
  const _StartupErrorApp();

  @override
  State<_StartupErrorApp> createState() => _StartupErrorAppState();
}

class _StartupErrorAppState extends State<_StartupErrorApp> {
  bool _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    if (await _initFirebase()) {
      await _startApp(); // replaces this screen with the app
    } else if (mounted) {
      setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SvcTheme.light(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: SvcColors.muted),
                const SizedBox(height: 16),
                const Text(
                  "Couldn't start QuickySewa",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: SvcColors.ink),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Something went wrong while starting the app. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: SvcColors.muted),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retrying ? null : _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SvcColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: SvcColors.primary,
                    disabledForegroundColor: Colors.white,
                    minimumSize: const Size(160, 48),
                  ),
                  child: _retrying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SharmaVideoCareApp extends StatefulWidget {
  final AppState appState;

  const SharmaVideoCareApp({super.key, required this.appState});

  @override
  State<SharmaVideoCareApp> createState() => _SharmaVideoCareAppState();
}

class _SharmaVideoCareAppState extends State<SharmaVideoCareApp> {
  // Built once. Screens listen to AppState and the language setting themselves, so
  // the app root never needs to rebuild.
  final ThemeData _theme = SvcTheme.light();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickySewa',
      debugShowCheckedModeBanner: false,
      theme: _theme,
      home: SplashScreen(appState: widget.appState),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final AppState appState;
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    required this.appState,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  // Tabs are built the first time they're opened and then kept alive, so switching
  // back doesn't resubscribe to Firestore or lose the scroll position.
  final Set<int> _openedTabs = {};

  // Kept-alive tabs only rebuild through this screen, so it listens to language too.
  late final Listenable _rebuildTriggers =
      Listenable.merge([widget.appState, SvcLocalization.languageNotifier]);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onNavigateTab(int index) {
    // A hidden tab keeps its state, so drop focus or the keyboard stays up.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentIndex = index);
  }

  Widget _buildCartBadge(int count) {
    return Positioned(
      right: -6,
      top: -4,
      child: Container(
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: BoxDecoration(
          color: SvcColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 9 ? '9+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _rebuildTriggers,
      builder: (context, _) {
        final user = widget.appState.currentUser;
        final isTechnician = user?.role == 'technician';
        final isNe = SvcLocalization.isNepali;

        final List<Widget> screens = [
          HomeScreen(appState: widget.appState, onNavigateTab: _onNavigateTab),
          ServiceRequestScreen(appState: widget.appState),
          ShopScreen(appState: widget.appState),
          UsedProductsScreen(appState: widget.appState),
          if (isTechnician)
            TechnicianPortalScreen(appState: widget.appState)
          else
            AccountScreen(appState: widget.appState, onNavigateTab: _onNavigateTab),
        ];

        final List<NavigationDestination> destinations = [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: SvcColors.primary),
            label: isNe ? 'गृहपृष्ठ' : 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.build_outlined),
            selectedIcon: const Icon(Icons.build_rounded, color: SvcColors.primary),
            label: isNe ? 'मर्मत' : 'Repair',
          ),
          NavigationDestination(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined),
                if (widget.appState.cartCount > 0)
                  _buildCartBadge(widget.appState.cartCount),
              ],
            ),
            selectedIcon: const Icon(Icons.shopping_bag, color: SvcColors.primary),
            label: isNe ? 'पसल' : 'Shop',
          ),
          NavigationDestination(
            icon: const Icon(Icons.verified_outlined),
            selectedIcon: const Icon(Icons.verified_rounded, color: SvcColors.primary),
            label: isNe ? 'पुरानो सामान' : 'Pre-Owned',
          ),
          if (isTechnician)
            NavigationDestination(
              icon: const Icon(Icons.handyman_outlined),
              selectedIcon: const Icon(Icons.handyman, color: SvcColors.primary),
              label: isNe ? 'मेरो काम' : 'My Jobs',
            )
          else
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person, color: SvcColors.primary),
              label: isNe ? 'खाता' : 'Account',
            ),
        ];

        final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;
        _openedTabs.add(safeIndex);

        return Scaffold(
          body: IndexedStack(
            index: safeIndex,
            children: [
              for (var i = 0; i < screens.length; i++)
                // TickerMode off pauses hidden tabs' animations; Home also checks
                // it to skip its carousel and countdown timers.
                TickerMode(
                  enabled: i == safeIndex,
                  child: _openedTabs.contains(i) ? screens[i] : const SizedBox.shrink(),
                ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: safeIndex,
            onDestinationSelected: _onNavigateTab,
            destinations: destinations,
            backgroundColor: SvcColors.surface,
            indicatorColor: SvcColors.primarySoft,
          ),
        );
      },
    );
  }
}
