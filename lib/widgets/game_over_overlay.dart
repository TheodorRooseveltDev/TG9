import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/game_constants.dart';
import '../constants/game_assets.dart';
import '../state/game_state.dart';

/// Game Over overlay with stats and restart button
class GameOverOverlay extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const GameOverOverlay({
    super.key,
    required this.gameState,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> with SingleTickerProviderStateMixin {
  bool _isRestartPressed = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    
    // Create smooth fade-in animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _initialized = true;
    
    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getGameOverMessage() {
    switch (widget.gameState.gameOverReason) {
      case 'popped':
        return 'BALLOON POPPED!';
      case 'deflated':
        return 'BALLOON DEFLATED!';
      case 'hit':
        return 'HIT BY HAZARD!';
      default:
        return 'GAME OVER!';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return simple version if not initialized (hot reload safety)
    if (!_initialized) {
      return Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: SizedBox(
            width: 800,
            height: 1000,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(GameAssets.bigModal, fit: BoxFit.fill),
              ],
            ),
          ),
        ),
      );
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: SizedBox(
              width: 800,
              height: 1000,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Big modal background
                  Image.asset(
                    GameAssets.bigModal,
                    fit: BoxFit.fill,
                  ),
                  
                  // Content - NO SCROLL, EVERYTHING VISIBLE!
                  Padding(
                    padding: const EdgeInsets.only(left: 190, right: 190, top: 110, bottom: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Game Over Message
                        Text(
                          _getGameOverMessage(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            shadows: [
                              const Shadow(
                                color: Colors.white54,
                                blurRadius: 3,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Stats - MINI TEXT!
                        _buildStat('Score', '${widget.gameState.currentScore}'),
                        const SizedBox(height: 3),
                        _buildStat('Coins', '${widget.gameState.sessionCoins}'),
                        const SizedBox(height: 3),
                        _buildStat('Best', '${widget.gameState.highScore}'),
                        
                        const SizedBox(height: 15),
                        
                        // Restart Button with smooth scale animation!
                        Listener(
                          onPointerDown: (_) {
                            setState(() => _isRestartPressed = true);
                          },
                          onPointerUp: (_) {
                            setState(() => _isRestartPressed = false);
                            widget.onRestart();
                          },
                          onPointerCancel: (_) {
                            setState(() => _isRestartPressed = false);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedScale(
                            scale: _isRestartPressed ? 0.85 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                            child: Image.asset(
                              GameAssets.restartButton,
                              width: 120,
                              height: 100,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C3E50), // Dark blue-gray
            shadows: [
              const Shadow(
                color: Colors.white70,
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: GameColors.balloonPrimary,
            shadows: [
              const Shadow(
                color: Colors.black,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
