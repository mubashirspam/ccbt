import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'view/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0XffDEAAFF),
        fontFamily: GoogleFonts.figtree().fontFamily,
      ),
      home: HomeScreen(),
    );
  }
}
