import 'package:baloon_twist/app_crash_logs/app_crash_logs_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Start with portrait mode for splash screen
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hide system UI for immersive full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const BalloonGame());
}

class BalloonGame extends StatelessWidget {
  const BalloonGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balloon Twist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const AppCrashLogsCheck(),
    );
  }
}
