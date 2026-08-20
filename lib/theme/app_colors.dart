import 'package:flutter/material.dart';

/// Palette compatible avec le logo (lavande + bleu)
class AppColors {
  // Couleurs principales (logo)
  static const Color primary = Color(0xFF2E6BE5);       // Bleu logo
  static const Color primaryDark = Color(0xFF1E4FB8);
  static const Color primaryLight = Color(0xFF5B8DEF);

  static const Color secondary = Color(0xFFEADAF0);     // Lavande logo
  static const Color secondaryDark = Color(0xFFD4B8E0);
  static const Color accent = Color(0xFF7C4DFF);        // Violet doux

  // Fonds
  static const Color background = Color(0xFFF8F7FC);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;

  // Texte
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // États
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Divers
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFE5E7EB);
  static const Color iconInactive = Color(0xFF9CA3AF);
  static const Color shadow = Color(0x1A000000);

  // Statuts voiture
  static const Color statusAvailable = Color(0xFF22C55E);
  static const Color statusSold = Color(0xFFEF4444);
  static const Color statusReserved = Color(0xFFF59E0B);
}
