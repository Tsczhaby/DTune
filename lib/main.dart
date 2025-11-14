import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/features/authentication/login_screen.dart';
import 'src/features/home/home_screen.dart';

void main() {
  runApp(const DTuneApp());
}

class DTuneApp extends StatelessWidget {
  const DTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2C3E50));

    return MaterialApp(
      title: 'DTune',
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
    );
  }
}
