import '../../features/game/domain/enums/card_color.dart';
import '../../features/game/domain/enums/card_level.dart';

/// Interface abstraite pour le service de tension
/// Gère la mécanique de tension/excitation du jeu
abstract class ITensionService {
  /// Vérifie si une carte peut être jouée selon le niveau de tension actuel
  bool canPlayCard(CardColor cardColor, CardLevel currentLevel);

  /// Calcule le niveau effectif basé sur la tension
  CardLevel getEffectiveLevel(double tension);

  /// Calcule l'augmentation de tension pour une couleur de carte
  double getTensionIncrease(CardColor cardColor);

  /// Vérifie si le niveau permet de jouer une couleur
  bool isColorUnlocked(CardColor color, CardLevel level);
}
