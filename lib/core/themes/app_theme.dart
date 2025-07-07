import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[900],
      
      colorScheme: ColorScheme.dark(
        primary: Colors.blue,
        secondary: Colors.cyan,
        surface: Colors.grey[850]!,
        background: Colors.grey[900]!,
        error: Colors.red[400]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue,
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      cardTheme: const CardThemeData(
        color: Colors.grey[850],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[800]!,
        labelStyle: const TextStyle(color: Colors.white70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.grey[850],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.roboto(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          color: Colors.white,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          color: Colors.white70,
        ),
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelMedium: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelSmall: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }
  
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color secondaryBlue = Color(0xFF03A9F4);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  
  static const List<Color> pieceColors = [
    Color(0xFF00BCD4), // Cyan - I piece
    Color(0xFFFFEB3B), // Yellow - O piece
    Color(0xFF9C27B0), // Purple - T piece
    Color(0xFF4CAF50), // Green - S piece
    Color(0xFFF44336), // Red - Z piece
    Color(0xFF2196F3), // Blue - J piece
    Color(0xFFFF9800), // Orange - L piece
  ];
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}