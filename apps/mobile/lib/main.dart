import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme_tokens.dart';
import 'state/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/service_request_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/account_screen.dart';
import 'screens/technician_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization: $e');
  }

  final appState = AppState();
  await appState.loadSession();

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
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Sharma Video Care',
          debugShowCheckedModeBanner: false,
          theme: SvcTheme.light(),
          home: SplashScreen(appState: widget.appState),
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

        final List<Widget> screens = [
          HomeScreen(appState: widget.appState, onNavigateTab: _onNavigateTab),
          ServiceRequestScreen(appState: widget.appState),
          ShopScreen(appState: widget.appState),
          if (isTechnician)
            TechnicianPortalScreen(appState: widget.appState)
          else
            ChatScreen(appState: widget.appState),
          AccountScreen(appState: widget.appState, onNavigateTab: _onNavigateTab),
        ];

        final List<NavigationDestination> destinations = [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFF97316)),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded, color: Color(0xFFF97316)),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Stack(
              children: [
                const Icon(Icons.inventory_2_outlined),
                if (widget.appState.cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
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
            selectedIcon: const Icon(Icons.inventory_2, color: Color(0xFFF97316)),
            label: 'Orders',
          ),
          if (isTechnician)
            const NavigationDestination(
              icon: Icon(Icons.handyman_outlined),
              selectedIcon: Icon(Icons.handyman, color: Color(0xFFF97316)),
              label: 'My Jobs',
            )
          else
            NavigationDestination(
              icon: Stack(
                children: [
                  const Icon(Icons.chat_bubble_outline),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              selectedIcon: const Icon(Icons.chat_bubble, color: Color(0xFFF97316)),
              label: 'Chat',
            ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFFF97316)),
            label: 'Profile',
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
