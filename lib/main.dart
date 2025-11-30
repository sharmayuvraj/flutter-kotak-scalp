import 'package:flutter/material.dart';
import 'screens/trading_screen.dart';
import 'services/neo_api_service.dart';

void main() {
  runApp(const NeoScalpApp());
}

class NeoScalpApp extends StatelessWidget {
  const NeoScalpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoScalp Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1624),
        fontFamily: 'SF Pro Display',
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: const TradingScreen(),
    );
  }
}