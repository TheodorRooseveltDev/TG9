import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/game_assets.dart';
import '../state/game_state.dart';

/// Beautiful splash screen with shop background, logo, and custom loader
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GameState _gameState = GameState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image (shop bg)
          Positioned.fill(
            child: Image.asset(GameAssets.shopBg, fit: BoxFit.cover),
          ),

          // Gradient overlay for better contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),

          // Logo in center
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/ui_elements/icon.png',
                width: 200,
                height: 200,
              ),
            ),
          ),

          // Custom loader at bottom
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: const CustomLoader(),
          ),
        ],
      ),
    );
  }
}

/// Beautiful custom loader with balloon animation
class CustomLoader extends StatefulWidget {
  const CustomLoader({super.key});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading text with animated dots
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final dots = ('.' * ((_controller.value * 3).floor() + 1)).padRight(
              3,
            );
            return Text(
              'Loading$dots',
              style: GoogleFonts.rubik(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
