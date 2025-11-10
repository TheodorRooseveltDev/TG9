import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/game_assets.dart';
import '../state/game_state.dart';
import 'onboarding_screen.dart';

/// Settings screen for sound, music, and other game options
class SettingsScreen extends StatefulWidget {
  final GameState gameState;

  const SettingsScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool soundEnabled;
  late bool musicEnabled;
  bool isResetButtonPressed = false;
  bool isChangeNameButtonPressed = false;

  @override
  void initState() {
    super.initState();
    soundEnabled = widget.gameState.soundEnabled;
    musicEnabled = widget.gameState.musicEnabled;
  }

  void _toggleSound() {
    setState(() {
      soundEnabled = !soundEnabled;
      widget.gameState.soundEnabled = soundEnabled;
      widget.gameState.saveData();
    });
  }

  void _toggleMusic() {
    setState(() {
      musicEnabled = !musicEnabled;
      widget.gameState.musicEnabled = musicEnabled;
      widget.gameState.saveData();
    });
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
          child: Column(
            children: [
              // Header with SETTINGS title and close button (like shop)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      'SETTINGS',
                      style: GoogleFonts.rubik(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 6,
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        GameAssets.closeButton,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 20),
                  child: Column(
                    children: [
                      // Audio Settings Section
                      _buildSection(
                        title: 'AUDIO',
                        child: Column(
                          children: [
                            _buildSettingRow(
                              label: 'Sound Effects',
                              isEnabled: soundEnabled,
                              onToggle: _toggleSound,
                            ),
                            const SizedBox(height: 12),
                            _buildSettingRow(
                              label: 'Music',
                              isEnabled: musicEnabled,
                              onToggle: _toggleMusic,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Statistics Section
                      _buildSection(
                        title: 'STATISTICS',
                        child: Column(
                          children: [
                            _buildStatRow(
                              label: 'Username',
                              value: widget.gameState.username,
                            ),
                            const Divider(height: 24, color: Colors.black12),
                            _buildStatRow(
                              label: 'High Score',
                              value: '${widget.gameState.highScore}',
                            ),
                            const Divider(height: 24, color: Colors.black12),
                            _buildStatRow(
                              label: 'Total Coins',
                              value: '${widget.gameState.totalCoins}',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Legal Section
                      _buildSection(
                        title: 'LEGAL',
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _openPrivacyPolicy,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Privacy Policy',
                                      style: GoogleFonts.rubik(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: Colors.black12),
                            GestureDetector(
                              onTap: _openTermsOfService,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Terms of Service',
                                      style: GoogleFonts.rubik(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Account Section
                      _buildSection(
                        title: 'ACCOUNT',
                        child: Column(
                          children: [
                            // Change Name Button
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: GestureDetector(
                                onTapDown: (_) {
                                  setState(() {
                                    isChangeNameButtonPressed = true;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    isChangeNameButtonPressed = false;
                                  });
                                  _showChangeNameDialog();
                                },
                                onTapCancel: () {
                                  setState(() {
                                    isChangeNameButtonPressed = false;
                                  });
                                },
                                child: AnimatedScale(
                                  scale: isChangeNameButtonPressed ? 0.7 : 1.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Image.asset(
                                    GameAssets.changeNameButton,
                                    width: 150,
                                    height: 60,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            // Reset All Button
                            GestureDetector(
                              onTapDown: (_) {
                                setState(() {
                                  isResetButtonPressed = true;
                                });
                              },
                              onTapUp: (_) {
                                setState(() {
                                  isResetButtonPressed = false;
                                });
                                _showResetConfirmation();
                              },
                              onTapCancel: () {
                                setState(() {
                                  isResetButtonPressed = false;
                                });
                              },
                              child: AnimatedScale(
                                scale: isResetButtonPressed ? 0.7 : 1.0,
                                duration: const Duration(milliseconds: 100),
                                child: Image.asset(
                                  GameAssets.resetAllButton,
                                  width: 150,
                                  height: 60,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    double titleTopOffset = 0,
    double contentTopOffset = 0,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dialogue modal background (maintain aspect ratio)
        Image.asset(
          GameAssets.dialogueModal,
          width: 650,
          fit: BoxFit.contain,
        ),
        
        // Content inside modal - aligned to top
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 100, right: 100, top: 50),
              child: Transform.translate(
                offset: Offset(0, contentTopOffset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category title (BLACK) with offset
                    Transform.translate(
                      offset: Offset(0, titleTopOffset),
                      child: Text(
                        title,
                        style: GoogleFonts.rubik(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Content
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required String label,
    required bool isEnabled,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black12,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isEnabled ? Colors.green.shade600 : Colors.grey.shade400,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rubik(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade700,
          ),
        ),
      ],
    );
  }

  void _openPrivacyPolicy() {
    _openInAppBrowser('https://www.example.com/privacy-policy');
  }

  void _openTermsOfService() {
    _openInAppBrowser('https://www.example.com/terms-of-service');
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset All Progress?',
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'This will delete all your progress, including:\n\n• High Score\n• Total Coins\n• Purchased Skins\n• Power-ups\n• All Settings\n\nThis action cannot be undone!',
            style: GoogleFonts.rubik(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetAllProgress();
              },
              child: Text(
                'Reset Everything',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangeNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: widget.gameState.username,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Change Username',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black26, width: 2),
            ),
            child: TextField(
              controller: nameController,
              textAlign: TextAlign.center,
              maxLength: 15,
              autofocus: true,
              style: GoogleFonts.rubik(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter new name',
                hintStyle: GoogleFonts.rubik(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black38,
                ),
                counterText: '',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Username cannot be empty!',
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
                
                widget.gameState.username = newName;
                await widget.gameState.saveData();
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Username updated to "$newName"!',
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Refresh the UI
                  setState(() {});
                }
              },
              child: Text(
                'Save',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Reset game state to defaults
    widget.gameState.resetToDefaults();
    
    if (mounted) {
      // Close settings screen and navigate to onboarding
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(gameState: widget.gameState),
        ),
      );
    }
  }

  Future<void> _openInAppBrowser(String url) async {
    final browser = ChromeSafariBrowser();
    await browser.open(
      url: WebUri(url),
      settings: ChromeSafariBrowserSettings(
        shareState: CustomTabsShareState.SHARE_STATE_OFF,
        barCollapsingEnabled: true,
      ),
    );
  }
}
