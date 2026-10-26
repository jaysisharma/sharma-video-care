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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Auth, orders and chat all depend on Firebase; show a retry screen instead of
    // letting the app crash later on first use.
    debugPrint('Firebase initialization failed: $e');
    runApp(const _StartupErrorApp());
    return;
  }

  await SvcLocalization.init();

  final appState = AppState();
  await appState.loadSession();

  runApp(SharmaVideoCareApp(appState: appState));
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

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
                const Icon(Icons.wifi_off_rounded, size: 48, color: SvcColors.muted),
                const SizedBox(height: 16),
                const Text(
                  "Couldn't start QuickySewa",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: SvcColors.ink),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: SvcColors.muted),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: main,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SvcColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 48),
                  ),
                  child: const Text('Try again'),
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
