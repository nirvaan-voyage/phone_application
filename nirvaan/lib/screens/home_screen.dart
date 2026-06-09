import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import 'login_screen.dart';

// ── Data model for each slide ──────────────────────────────────────────────
class _SlideData {
  const _SlideData({
    required this.imagePath,
    required this.smallText,
    required this.bigText,
  });
  final String imagePath;
  final String smallText;
  final String bigText;
}

const List<_SlideData> _slides = [
  _SlideData(
    imagePath: 'assets/images/img1.jpg',
    smallText: 'Find your peace',
    bigText: 'DISCOVER NATURE',
  ),
  _SlideData(
    imagePath: 'assets/images/img2.jpg',
    smallText: 'Feel the freedom',
    bigText: 'EXPLORE THE WORLD',
  ),
  _SlideData(
    imagePath: 'assets/images/img3.jpg',
    smallText: 'Get ready for',
    bigText: 'NEW ADVENTURES',
  ),
];

// ── Main Screen ────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_currentPage < _slides.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // ── Full screen PageView ─────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) =>
                setState(() => _currentPage = index),
            itemBuilder: (_, index) => _SlideWidget(
              slide: _slides[index],
            ),
          ),

          // ── Bottom overlay: dots + button ────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Slide text (small + big)
                    _SlideText(slide: _slides[_currentPage]),

                    const SizedBox(height: 32),

                    // Dot indicators
                    _DotIndicators(
                      count: _slides.length,
                      current: _currentPage,
                    ),

                    const SizedBox(height: 32),

                    // CTA button — only on last slide
                    AnimatedOpacity(
                      opacity:
                          _currentPage == _slides.length - 1 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: _currentPage == _slides.length - 1
                          ? _LetsTourButton(onTap: _goToLogin)
                          : const SizedBox(height: 52),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single slide background ────────────────────────────────────────────────
class _SlideWidget extends StatelessWidget {
  const _SlideWidget({required this.slide});
  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset(
          slide.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryLight, AppColors.primaryDark],
              ),
            ),
          ),
        ),

        // Dark gradient overlay (bottom heavy)
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Slide text block ───────────────────────────────────────────────────────
class _SlideText extends StatelessWidget {
  const _SlideText({required this.slide});
  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          slide.smallText,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          slide.bigText,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.5,
            height: 1.1,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Dot indicators ─────────────────────────────────────────────────────────
class _DotIndicators extends StatelessWidget {
  const _DotIndicators({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Let's Tour button ──────────────────────────────────────────────────────
class _LetsTourButton extends StatelessWidget {
  const _LetsTourButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Let's Tour",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}