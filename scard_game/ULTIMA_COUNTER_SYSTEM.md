# Système de Compteur Ultima

## Vue d'ensemble
Le système de compteur Ultima permet de gérer la condition de victoire spéciale de la carte **Ultima (red_016)**.

## Règles
1. **Activation** : Quand un joueur joue Ultima, un compteur se met en place
2. **Incrémentation** : Le compteur augmente de 1 à chaque fin de tour (phase End → Draw) si le joueur a toujours Ultima en jeu
3. **Victoire** : À 3 tours complets, le joueur qui a Ultima gagne automatiquement la partie
4. **Réinitialisation** : Si Ultima retourne en main (destruction, contre), le compteur se réinitialise à 0

## Cas spéciaux
### Deux joueurs avec Ultima
- Si les 2 joueurs ont Ultima en jeu, **seul le premier** à l'avoir posé fait avancer le compteur
- Le système utilise `ultimaPlayedAt` (timestamp) pour déterminer qui l'a posé en premier

### Transfert de compteur
- Si le joueur ayant le compteur actif détruit son Ultima
- ET que l'adversaire a toujours Ultima en jeu
- Alors le compteur est **transféré à l'adversaire** et redémarre à 0

### Destruction
- Quand Ultima est détruit (via popup ou carte "Négociations"), la carte retourne en main
- Si plus aucun joueur n'a Ultima, le compteur est réinitialisé complètement

## Implémentation technique

### Champs GameSession
```dart
String? ultimaOwnerId;        // ID du joueur avec le compteur actif
int ultimaTurnCount;          // Nombre de tours (0-3)
DateTime? ultimaPlayedAt;     // Timestamp pour départager
```

### Logique d'activation (clearPlayedCards)
```dart
// Détecte si Ultima vient d'être jouée
final ultimaJustPlayed = enchantments.any((id) => id.contains('red_016'));

if (ultimaJustPlayed) {
  if (ultimaOwnerId == null) {
    // Premier joueur à poser Ultima
    ultimaOwnerId = currentPlayerId;
    ultimaTurnCount = 0;
    ultimaPlayedAt = DateTime.now();
  }
  // Si un autre joueur avait déjà Ultima, le compteur ne change pas
}
```

### Logique d'incrémentation (nextPhase)
```dart
// À chaque transition Resolution → End
if (currentPhase == GamePhase.resolution && nextPhase == GamePhase.end) {
  if (ultimaOwnerId != null) {
    // Vérifier que le joueur a toujours Ultima
    final ownerHasUltima = ownerData.activeEnchantmentIds.any((id) => id.contains('red_016'));
    
    if (ownerHasUltima) {
      ultimaTurnCount++;
      
      // Victoire à 3 tours
      if (ultimaTurnCount >= 3) {
        winnerId = ultimaOwnerId;
        status = GameStatus.finished;
      }
    }
  }
}
```

### Logique de réinitialisation (removeEnchantment)
```dart
if (isUltima && ultimaOwnerId == playerId) {
  // Le joueur avec le compteur retire son Ultima
  final opponentHasUltima = opponentData.activeEnchantmentIds.any((id) => id.contains('red_016'));
  
  if (opponentHasUltima) {
    // Transférer le compteur à l'adversaire
    ultimaOwnerId = opponentId;
    ultimaTurnCount = 0;
    ultimaPlayedAt = DateTime.now();
  } else {
    // Personne n'a plus Ultima
    ultimaOwnerId = null;
    ultimaTurnCount = 0;
    ultimaPlayedAt = null;
  }
}
```

## Interface utilisateur

### Compteur Ultima (_buildUltimaCounter)
- Affiché en dessous du badge de phase
- Couleur selon le compteur :
  - Tour 0 : Violet
  - Tour 1 : Orange
  - Tour 2 : Rouge (alerte)
- Indique : "ULTIMA (VOUS)" ou "ULTIMA (ADVERSAIRE)"
- Affiche : "Tour X/3"

### Écran de victoire (_buildVictoryScreen)
- S'affiche automatiquement quand `status == GameStatus.finished`
- Affiche le message de victoire/défaite Ultima
- Rappelle la récompense : "Vous devez/recevez un orgasme"

## Tests
Pour tester le système :
1. Monter à 100% de tension pour recevoir Ultima
2. Jouer Ultima en tant qu'enchantement
3. Passer 3 tours complets sans le détruire
4. Vérifier l'écran de victoire

Ou :
1. Les 2 joueurs jouent Ultima
2. Vérifier que seul le 1er voit le compteur augmenter
3. Détruire l'Ultima du 1er joueur
4. Vérifier que le compteur se transfère au 2ème joueur à 0
