import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

  // Custom ErrorWidget so release mode never shows a blank grey screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: SvcColors.canvas,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: SvcColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Screen Notice',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: SvcColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  details.exceptionAsString(),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: SvcColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // Initialize Firebase gracefully.
  // We first initialize with DefaultFirebaseOptions. If the native platform
  // (Android/iOS) already created the [DEFAULT] instance, we bind to it
  // via Firebase.app() on duplicate-app. Otherwise we fallback cleanly.
  try {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on FirebaseException catch (e) {
        if (e.code == 'duplicate-app') {
          Firebase.app();
        } else {
          rethrow;
        }
      }
    }
  } catch (e) {
    try {
      Firebase.app();
    } catch (_) {
      try {
        await Firebase.initializeApp();
      } catch (fallbackError) {
        debugPrint('Firebase initialization notice: $e | Fallback: $fallbackError');
      }
    }
  }

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

class SharmaVideoCareApp extends StatefulWidget {
  final AppState appState;

  const SharmaVideoCareApp({super.key, required this.appState});

  @override
  State<SharmaVideoCareApp> createState() => _SharmaVideoCareAppState();
}

class _SharmaVideoCareAppState extends State<SharmaVideoCareApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SvcLocalization.languageNotifier,
      builder: (context, currentLang, _) {
        return ListenableBuilder(
          listenable: widget.appState,
          builder: (context, _) {
            return MaterialApp(
              title: 'QuickySewa',
              debugShowCheckedModeBanner: false,
              theme: SvcTheme.light(),
              home: SplashScreen(appState: widget.appState),
            );
          },
        );
      },
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onNavigateTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
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
              children: [
                const Icon(Icons.shopping_bag_outlined),
                if (widget.appState.cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: SvcColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.appState.cartCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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

        return Scaffold(
          body: screens[safeIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: safeIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: destinations,
            backgroundColor: SvcColors.surface,
            indicatorColor: SvcColors.primarySoft,
          ),
        );
      },
    );
  }
}
