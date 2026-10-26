import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../main.dart';
import '../widgets/brand_logo.dart';

class SplashScreen extends StatefulWidget {
  final AppState appState;

  const SplashScreen({super.key, required this.appState});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();

    // Show the brand for a moment, and give the background profile check a short
    // window so a blocked or changed-role account is resolved before the first screen.
    Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 1400)),
      widget.appState.waitForSession(timeout: const Duration(seconds: 3)),
    ]).then((_) {
      if (!mounted) return;
      // Guests land on Home; signing in is optional and lives in the Account tab.
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MainNavigationScreen(appState: widget.appState),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Precision Aperture Emblem
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x080F172A),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const SvcBrandLogo.markOnly(size: 88),
                ),
                const SizedBox(height: 28),

                // Brand Name — Clean, Timeless Swiss Typography
                Text(
                  'QUICKYSEWA',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                    color: SvcColors.ink,
                  ),
                ),
                const SizedBox(height: 10),

                // Warm Accent Division Bar
                Container(
                  width: 28,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: SvcColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),

                // Sub-title
                Text(
                  'CAMERA CRAFT & ELECTRONICS LAB',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.6,
                    color: SvcColors.muted,
                  ),
                ),
                const SizedBox(height: 6),

                // Heritage Tag
                Text(
                  'EST. 2004  •  JANAKPUR',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
