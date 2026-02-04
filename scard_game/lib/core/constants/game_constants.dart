/// Constantes globales du jeu S'Card
/// Centralise les magic numbers et magic strings pour faciliter la maintenance
class GameConstants {
  GameConstants._(); // Empêche l'instanciation

  // === Cartes spéciales ===
  static const String ultimaCardId = 'red_016';
  static const String ultimaCardName = 'ULTIMA';

  // === Limites de main ===
  static const int maxHandSize = 7;
  static const int initialHandSize = 5;
  static const int minHandSizeBeforeDraw = 3;

  // === Points d'Intimité (PI) ===
  static const int initialPI = 5;
  static const int maxPI = 99;
  static const int minPI = 0;

  // === Tension ===
  static const double maxTension = 100.0;
  static const double minTension = 0.0;

  // Montants de tension par couleur de carte
  static const Map<String, double> tensionByCardColor = {
    'white': 5.0,
    'blue': 10.0,
    'yellow': 15.0,
    'red': 20.0,
    'green': 0.0, // Cartes de négociation
  };

  // Seuils de tension pour débloquer les niveaux
  static const double tensionThresholdBlue = 25.0;
  static const double tensionThresholdYellow = 50.0;
  static const double tensionThresholdRed = 75.0;

  // === Compteur ULTIMA ===
  static const int ultimaMaxCount = 5;
  static const int ultimaInitialCount = 0;

  // === Deck ===
  static const int deckSize = 30;

  // === UI Timings (en millisecondes) ===
  static const int dragDropDelay = 100;
  static const int longPressDelay = 150;
  static const int animationDuration = 200;
  static const int snackbarDuration = 2000;

  // === Code de partie ===
  static const int gameCodeLength = 6;
  static const String gameCodeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
}
