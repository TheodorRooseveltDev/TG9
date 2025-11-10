import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/game_assets.dart';
import '../state/game_state.dart';
import 'game_screen.dart';

/// Onboarding screen with tutorial and username setup
class OnboardingScreen extends StatefulWidget {
  final GameState gameState;

  const OnboardingScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _usernameController = TextEditingController();
  int _currentPage = 0;
  final int _totalPages = 6; // 5 tutorial pages + 1 username page

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a username!',
            style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save username and mark onboarding as complete
    widget.gameState.username = username;
    widget.gameState.hasCompletedOnboarding = true;
    await widget.gameState.saveData();

    if (mounted) {
      // Navigate to the game screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const GameScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(GameAssets.shopBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content - full screen
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildMovementPage(),
                  _buildCollectiblesPage(),
                  _buildHazardsPage(),
                  _buildPowerUpsPage(),
                  _buildUsernamePage(),
                ],
              ),

              // Page indicator - positioned at top
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 40 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: _currentPage == index
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),

              // Navigation buttons - absolutely positioned at bottom
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    if (_currentPage > 0)
                      GestureDetector(
                        onTap: _previousPage,
                        child: Image.asset(
                          GameAssets.leftButton,
                          width: 60,
                          height: 60,
                        ),
                      )
                    else
                      const SizedBox(width: 60),

                    // Next/Start button
                    if (_currentPage < _totalPages - 1)
                      GestureDetector(
                        onTap: _nextPage,
                        child: Image.asset(
                          GameAssets.rightButton,
                          width: 60,
                          height: 60,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _completeOnboarding,
                        child: Image.asset(
                          GameAssets.startButton,
                          width: 150,
                          height: 60,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 60, bottom: 120, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              // Title
              Text(
                'WELCOME TO\nBALLOON TWIST!',
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Balloon image
              Image.asset(
                GameAssets.getBalloonSkinImagePath('classic')['balloon']!,
                width: 200,
                height: 200,
              ),
              
              const SizedBox(height: 40),
              
              const SizedBox(height: 40),
          
          // Description with frame background
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                GameAssets.dialogueModal,
                width: 500,
                fit: BoxFit.contain,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                child: Text(
                  'Tap to inflate and navigate!\nCollect coins, avoid hazards!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
            ],
      ),
    );
  }

  Widget _buildMovementPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 60, bottom: 120, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Text(
                'MOVEMENT',
                style: GoogleFonts.rubik(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(GameAssets.leftButton, width: 80, height: 80),
                  const SizedBox(width: 40),
                  Image.asset(
                    GameAssets.getBalloonSkinImagePath('classic')['balloon']!,
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(width: 40),
                  Image.asset(GameAssets.rightButton, width: 80, height: 80),
                ],
              ),
              
              const SizedBox(height: 50),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    GameAssets.dialogueModal,
                    width: 500,
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                    child: Text(
                      'Tap LEFT or RIGHT to move\nKeep tapping to stay inflated!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
      ),
    );
  }

  Widget _buildCollectiblesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 60, bottom: 120, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Text(
                'COLLECT COINS',
                style: GoogleFonts.rubik(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              Image.asset(GameAssets.shopCoin, width: 120, height: 120),
              
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    GameAssets.getBalloonSkinImagePath('fire')['balloon']!,
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 15),
                  Image.asset(
                    GameAssets.getBalloonSkinImagePath('ice')['balloon']!,
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(width: 15),
                  Image.asset(
                    GameAssets.getBalloonSkinImagePath('rainbow')['balloon']!,
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    GameAssets.dialogueModal,
                    width: 500,
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                    child: Text(
                      'Buy cool skins & power-ups\nin the shop!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
      ),
    );
  }

  Widget _buildHazardsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 60, bottom: 120, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Text(
                'AVOID HAZARDS',
                style: GoogleFonts.rubik(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/hazards/pin_red.png', width: 60, height: 60),
                      const SizedBox(width: 20),
                      Image.asset('assets/hazards/needle_blue.png', width: 60, height: 60),
                      const SizedBox(width: 20),
                      Image.asset('assets/hazards/dart_green.png', width: 60, height: 60),
                      const SizedBox(width: 20),
                      Image.asset('assets/hazards/tack_yellow.png', width: 60, height: 60),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 50),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    GameAssets.dialogueModal,
                    width: 500,
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                    child: Text(
                      'Sharp objects will pop you!\nStay alert and dodge!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
      ),
    );
  }

  Widget _buildPowerUpsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 60, bottom: 120, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Text(
                'POWER-UPS',
                style: GoogleFonts.rubik(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(GameAssets.shieldEffectImage, width: 70, height: 70),
                  const SizedBox(width: 25),
                  Image.asset(GameAssets.magnetEffectImage, width: 70, height: 70),
                  const SizedBox(width: 25),
                  Image.asset(GameAssets.freezeEffectImage, width: 70, height: 70),
                ],
              ),
              
              const SizedBox(height: 50),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    GameAssets.dialogueModal,
                    width: 500,
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                    child: Text(
                      'Shield • Magnet • Freeze\nUse them to survive longer!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
      ),
    );
  }

  Widget _buildUsernamePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 60, bottom: 120, left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Text(
                'ONE LAST THING!',
                style: GoogleFonts.rubik(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    GameAssets.dialogueModal,
                    width: 500,
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 50),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Enter your username:',
                          style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 250,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26, width: 2),
                          ),
                          child: TextField(
                            controller: _usernameController,
                            textAlign: TextAlign.center,
                            maxLength: 15,
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Player Name',
                              hintStyle: GoogleFonts.rubik(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black38,
                              ),
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
      ),
    );
  }
}
