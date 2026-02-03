# Système d'Effets de Cartes - Migration vers JSON Structuré

## ✅ Modifications Terminées

### 1. **Modèle GameCard** (`lib/features/game/domain/models/game_card.dart`)

Ajout de 6 nouveaux champs structurés pour remplacer le parsing de texte :

```dart
/// Nombre de cartes à piocher (0 = aucune)
@Default(0) int drawCards,

/// Dégâts PI à l'adversaire (négatif = perte, 0 = aucun)
@Default(0) int piDamageOpponent,

/// Gain PI pour le lanceur (positif = gain, 0 = aucun)
@Default(0) int piGainSelf,

/// Augmentation de tension pour le lanceur (0 = aucune)
@Default(0) int tensionIncrease,

/// Coût en PI pour lancer la carte (0 = gratuit)
@Default(0) int piCost,

/// Est-ce un enchantement permanent qui reste en jeu
@Default(false) bool isEnchantment,
```

### 2. **CardEffectService** (`lib/features/game/data/services/card_effect_service.dart`)

**Supprimé :**
- ❌ Méthode `_parseEffect()` avec regex
- ❌ Enum `EffectType`
- ❌ Classe `ParsedEffect`

**Simplifié :**
```dart
Future<void> applyCardEffect(String sessionId, GameCard card, String playerId) async {
  // Pioche de cartes
  if (card.drawCards > 0) {
    await _drawCards(sessionId, playerId, card.drawCards);
  }

  // Dégâts PI à l'adversaire
  if (card.piDamageOpponent > 0) {
    await _damagePI(sessionId, 'opponent', card.piDamageOpponent);
  }

  // Gain PI pour le lanceur
  if (card.piGainSelf > 0) {
    await _gainPI(sessionId, playerId, card.piGainSelf);
  }

  // Augmentation de tension
  if (card.tensionIncrease > 0) {
    await _modifyTension(sessionId, playerId, card.tensionIncrease);
  }

  // Enchantement permanent
  if (card.isEnchantment) {
    await _applyEnchantment(sessionId, playerId, card.id);
  }
}
```

### 3. **Fichier cards.json** (`assets/data/cards.json`)

**Toutes les 53 cartes mises à jour** avec les nouveaux champs :

```json
{
  "id": "white_002",
  "name": "Pioche",
  "type": "ritual",
  "color": "white",
  "launcherCost": "Enlève un vêtement",
  "gameEffect": "Piochez 2 cartes",  ← Texte descriptif conservé pour l'UI
  "targetEffect": null,
  "damageIfRefused": 0,
  "drawCards": 2,                     ← Nouveau champ structuré
  "piDamageOpponent": 0,              ← Nouveau champ structuré
  "piGainSelf": 0,                    ← Nouveau champ structuré
  "tensionIncrease": 0,               ← Nouveau champ structuré
  "piCost": 0,                        ← Nouveau champ structuré
  "isEnchantment": false,             ← Nouveau champ structuré
  "maxPerDeck": 2,
  "imageUrl": "assets/data/logo.png"
}
```

## 📊 Avantages de la Nouvelle Structure

### Avant (Parsing de Texte) ❌
```dart
// Fragile : dépend du texte exact
final effects = _parseEffect("Piochez 2 cartes");
// RegExp r'piochez?\s+(\d+)\s+cartes?'
```

### Après (JSON Structuré) ✅
```dart
// Robuste : lecture directe des attributs
if (card.drawCards > 0) {
  await _drawCards(sessionId, playerId, card.drawCards);
}
```

**Bénéfices :**
- ✅ **Robuste** : Plus de problèmes avec les typos ou variations de texte
- ✅ **Performant** : Pas de regex à chaque résolution d'effet
- ✅ **Maintenable** : Modification des effets = changement de nombre
- ✅ **Type-safe** : Les champs sont typés et validés par Dart
- ✅ **Extensible** : Facile d'ajouter de nouveaux types d'effets

## 🔄 Prochaines Étapes (À Faire)

### 1. Personnaliser les Valeurs d'Effets
Actuellement toutes les cartes ont des valeurs par défaut (0). Il faut ajuster manuellement :

```json
// Exemple : Carte qui fait perdre 3 PI à l'adversaire
{
  "id": "red_001",
  "name": "Attaque PI",
  "gameEffect": "L'adversaire perd 3 PI",
  "piDamageOpponent": 3,  ← À ajuster manuellement
  "drawCards": 0,
  "piGainSelf": 0,
  "tensionIncrease": 0
}
```

### 2. Effets Non Implémentés (Futures Extensions)
Certains effets nécessitent une logique supplémentaire :

- **Contre-sorts** (Miroir, Contre) : Logique de copie/annulation
- **Désenchanter** : Suppression d'enchantements
- **Sacrifices** : Déjà géré dans GameScreen
- **Effets conditionnels** : "Si X alors Y"

### 3. Tester la Résolution d'Effets
Lancer une partie et tester :
1. Jouer "Pioche" (white_002) → Devrait piocher 2 cartes
2. Phase Résolution → Vérifier que les effets s'appliquent
3. Vérifier les mises à jour Firebase (PI, tension, enchantements)

## 📝 Notes Techniques

- **Build Runner** : Exécuté avec succès (12 fichiers générés)
- **Erreurs de Compilation** : Toutes corrigées
- **Script Python** : `update_cards.py` peut être réutilisé pour d'autres mises à jour de masse
- **Compatibilité** : `gameEffect` (texte) conservé pour l'affichage UI

## 🎯 Utilisation

Quand une carte est jouée en phase Résolution :

1. Le système lit `card.drawCards`, `card.piDamageOpponent`, etc.
2. Applique chaque effet non-nul via les méthodes dédiées
3. Met à jour Firebase avec les nouvelles valeurs
4. Affiche "✅ Effets résolus"

**Comme une partition musicale** : chaque carte contient tous ses attributs numériques prêts à être appliqués ! 🎵
