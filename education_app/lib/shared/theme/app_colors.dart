import 'package:flutter/material.dart';

/// Centralized color palette for the Education App.
/// Use these colors via Theme.of(context).colorScheme or directly via AppColors.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================
  // PRIMARY COLORS (Education/Trust - Blue)
  // ============================================
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant Blue
  static const Color primaryDark = Color(0xFF6C63FF);  // Indigo/Purple
  static const Color onPrimary = Colors.white;

  // ============================================
  // SECONDARY COLORS (Action/Highlight - Orange/Amber)
  // ============================================
  static const Color secondaryLight = Color(0xFFF59E0B); // Amber
  static const Color secondaryDark = Color(0xFFB24BF3);  // Purple Accent
  static const Color onSecondary = Colors.white;

  // ============================================
  // ACCENT / TERTIARY (Highlight)
  // ============================================
  static const Color accentLight = Color(0xFF10B981); // Emerald Green
  static const Color accentDark = Color(0xFF00D9FF);  // Cyan

  // ============================================
  // SURFACE / BACKGROUND (Light Mode)
  // ============================================
  static const Color backgroundLight = Color(0xFFF8FAFC); // Very Light Gray
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;

  // ============================================
  // SURFACE / BACKGROUND (Dark Mode)
  // ============================================
  static const Color backgroundDark = Color(0xFF0A0E27); // Deep Navy
  static const Color surfaceDark = Color(0xFF1A1F3A);    // Slate Blue
  static const Color cardDark = Color(0xFF252B48);       // Card Surface

  // ============================================
  // TEXT COLORS
  // ============================================
  static const Color textPrimaryLight = Color(0xFF1E293B);  // Slate 800
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400

  static const Color textPrimaryDark = Color(0xFFF5F5FA);   // Off-white
  static const Color textSecondaryDark = Color(0xFFE8E8F0); // Light Gray
  static const Color textTertiaryDark = Color(0xFFB8B8CC);  // Muted Gray

  // ============================================
  // STATUS COLORS
  // ============================================
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color error = Color(0xFFEF4444);   // Red 500
  static const Color warning = Color(0xFFF97316); // Orange 500
  static const Color info = Color(0xFF3B82F6);    // Blue 500

  // ============================================
  // QUIZ SPECIFIC
  // ============================================
  static const Color correctAnswer = Color(0xFF22C55E);
  static const Color wrongAnswer = Color(0xFFEF4444);
  static const Color selectedOption = Color(0xFFDBEAFE); // Blue 100
  
  // Quiz backgrounds
  static const Color quizCorrectBackground = Color(0xFFDCFCE7); // Green 100
  static const Color quizWrongBackground = Color(0xFFFEE2E2);   // Red 100
  static const Color quizSelectedOption = Color(0xFFDBEAFE);    // Blue 100

  // ============================================
  // BORDERS & DIVIDERS
  // ============================================
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderDark = Color(0xFF374151);  // Gray 700
  static const Color dividerLight = Color(0xFFE5E7EB); // Gray 200
  static const Color dividerDark = Color(0xFF4B5563);  // Gray 600

  // ============================================
  // GRADIENTS
  // ============================================
  static const LinearGradient primaryGradientLight = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)], // Blue to Purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFB24BF3)], // Indigo to Purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradientLight = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], // Blue 500 to Purple 500
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF5B21B6)], // Blue 900 to Purple 800
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ============================================
  // SEARCH SPECIFIC
  // ============================================
  static const Color searchBarBorderLight = Color(0xFFBFDBFE); // Blue 200
  static const Color searchBarBorderDark = Color(0xFF3A4168);  // Slate Border
  static const Color searchHighlightLight = Color(0xFFFEF08A); // Yellow 200 (Background)
  static const Color searchHighlightDark = Color(0x4DFBBF24);  // Amber with 30% alpha
  static const Color searchHighlightTextLight = Color(0xFF9A3412); // Amber 800
  static const Color searchHighlightTextDark = Color(0xFFFDE68A);  // Amber 200
  static const Color searchIconLight = Color(0xFF93C5FD);     // Blue 300
  static const Color searchIconDark = Color(0xFF6A6F8D);      // Slate Muted
  static const Color searchShadowLight = Color(0x1A2563EB);   // Subtle Blue shadow
  static const Color searchShadowDark = Color(0x4D000000);    // Dark shadow

  // ============================================
  // TOPIC PAGE SPECIFIC
  // ============================================

  // پس‌زمینه (Background gradients)
  static const Color backgroundDeepDark          = Color(0xFF16213E); // سومین لایه gradient پس‌زمینه dark
  static const Color backgroundGradientStartLight = Color(0xFFEFF6FF); // معادل Colors.blue.shade50

  // هدر AppBar - حالت روشن (Light mode AppBar header)
  static const Color appBarGradientStartLight    = Color(0xFF1D4ED8); // معادل Colors.blue.shade700
  static const Color appBarGradientEndLight      = Color(0xFF3B82F6); // معادل Colors.blue.shade500

  // آیکون روی هدر (Icon overlay on header)
  static const Color iconHeaderOverlay           = Color(0xB3FFFFFF); // معادل Colors.white70

  // حالت خطا (Error state)
  static const Color errorIcon                   = Color(0xFFFC8181); // معادل Colors.red.shade300

  // BottomSheet انتخاب محتوا (Content Selection BottomSheet)
  static const Color sheetSubtitleDark           = Color(0xFFBDBDBD); // معادل Colors.grey[400]
  static const Color sheetSubtitleLight          = Color(0xFF757575); // معادل Colors.grey[600]

  // آیکون آموزش (Education icon)
  static const Color educationIconBackground     = Color(0x1A3B82F6); // blue با ۱۰٪ alpha
  // (رنگ اصلی آیکون آموزش = AppColors.info)

  // آیکون آزمون (Quiz icon)
  static const Color quizIconBackground          = Color(0x1A22C55E); // green با ۱۰٪ alpha
  // (رنگ اصلی آیکون آزمون = AppColors.success)
}

