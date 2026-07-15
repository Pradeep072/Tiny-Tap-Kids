import 'package:flutter/material.dart';
import 'screens/language_screen.dart';

void main() {
  runApp(const TinyTapKidsApp());
}

class TinyTapKidsApp extends StatelessWidget {
  const TinyTapKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiny Tap Kids',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Comic Sans MS',
        useMaterial3: true,
      ),
      home: const LanguageScreen(),
    );
  }
}
