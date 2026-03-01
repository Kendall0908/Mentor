import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Palette ───
  static const Color primary = Color(0xFF1E88E5);       // Bleu — couleur principale
  static const Color primaryLight = Color(0xFFE3F2FD);  // Bleu clair (backgrounds, chips)
  static const Color accent = Color(0xFFF79E1B);        // Orange — accent secondaire

  // ─── Neutral Palette ───
  static const Color background = Color(0xFFFAFAFA);    // Fond global uniforme
  static const Color surface = Colors.white;             // Cards, AppBars, modals
  static const Color divider = Color(0xFFF0F0F0);       // Séparateurs

  // ─── Text ───
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ─── Semantic ───
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);

  // ─── Legacy aliases (pour compatibilité, pointe vers primary) ───
  static const Color questBlue = primary;
  static const Color questBlueLight = primaryLight;
  static const Color textBlack = textPrimary;
  static const Color textGrey = textSecondary;
  static const Color secondary = surface;

  // ─── Design Tokens ───
  static const double cardRadius = 20.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius = 12.0;

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
}
