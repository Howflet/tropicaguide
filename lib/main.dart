import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home_trips_screen.dart';
import 'screens/welcome_sign_in_screen.dart';
import 'services/auth_service.dart';
import 'theme/tropica_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Allows running in test or offline environments without platform channels
  }
  runApp(TropicaGuideApp(authService: AuthService()));
}

class TropicaGuideApp extends StatelessWidget {
  final AuthService authService;

  const TropicaGuideApp({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TropicaGuide',
      debugShowCheckedModeBanner: false,
      theme: TropicaTheme.light(),
      home: ListenableBuilder(
        listenable: authService,
        builder: (context, _) {
          if (authService.isAuthenticated) {
            return HomeTripsScreen(authService: authService);
          }
          return WelcomeSignInScreen(authService: authService);
        },
      ),
    );
  }
}
