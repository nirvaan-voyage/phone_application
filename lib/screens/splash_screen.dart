import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/nirvaan_logo.dart';
import 'main_app_screen.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _controller.forward();
    _initSession();
  }

  Future<void> _initSession() async {
    // Run session restoration in parallel with the animation.
    // The animation takes 1400ms; we wait at least that long so the splash
    // is never cut short, but we don't add unnecessary extra delay.
    await Future.wait([
      ref.read(authProvider.notifier).restoreSession(),
      Future.delayed(const Duration(milliseconds: 1800)),
    ]);
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;

    final auth = ref.read(authProvider);

    // First launch (no prior session and no stored token) → show onboarding
    // Returning guest / logged-in user → go straight into the app
    final destination = auth.isLoggedIn ? const MainAppScreen() : _resolveFirstDestination();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  /// Determines whether to show the onboarding slides or go directly to
  /// MainAppScreen for returning guests.
  /// Currently: always show HomeScreen (onboarding) for non-logged-in users
  /// so the "Let's Tour" CTA acts as the entry point.
  Widget _resolveFirstDestination() => const HomeScreen();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: const NirvaanLogo(size: 300, showTagline: true),
          ),
        ),
      ),
    );
  }
}
