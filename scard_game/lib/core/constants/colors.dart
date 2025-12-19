import 'dart:ui';

/// Couleurs du thème de l'application
class AppColors {
  AppColors._();

  // === COULEURS PRINCIPALES ===
  static const Color primary = Color(0xFFE53935); // Rouge passion
  static const Color secondary = Color(0xFF9C27B0); // Violet mystérieux
  static const Color accent = Color(0xFFFFD700); // Or luxueux

  // === COULEURS DE FOND ===
  static const Color background = Color(0xFF121212); // Noir profond
  static const Color surface = Color(0xFF1E1E1E); // Gris très foncé
  static const Color surfaceVariant = Color(0xFF2A2A2A); // Gris foncé

  // === COULEURS DE TEXTE ===
  static const Color textPrimary = Color(0xFFFFFFFF); // Blanc
  static const Color textSecondary = Color(0xFFB0B0B0); // Gris clair
  static const Color textDisabled = Color(0xFF666666); // Gris moyen

  // === COULEURS DES CARTES ===
  static const Color cardWhite = Color(0xFFE8E8E8); // Blanc innocent
  static const Color cardBlue = Color(0xFF64B5F6); // Bleu séduction
  static const Color cardYellow = Color(0xFFFFEB3B); // Jaune passion
  static const Color cardRed = Color(0xFFE53935); // Rouge extase

  // === COULEURS DE STATUT ===
  static const Color success = Color(0xFF4CAF50); // Vert
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFF44336); // Rouge
  static const Color info = Color(0xFF2196F3); // Bleu

  // === COULEURS DE LA JAUGE DE TENSION ===
  static const List<Color> tensionGradient = [
    cardWhite, // 0-25%
    cardBlue, // 25-50%
    cardYellow, // 50-75%
    cardRed, // 75-100%
  ];
}
