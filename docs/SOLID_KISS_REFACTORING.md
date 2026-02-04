# 🏗️ Refactoring SOLID/KISS - S'Card

## 📋 Objectifs du Refactoring

L'objectif est de rendre le projet **modulable et évolutif** en appliquant :
- **Principes SOLID** : S-ingle responsibility, O-pen/closed, L-iskov substitution, I-nterface segregation, D-ependency inversion
- **Principe KISS** : Keep It Simple, Stupid

---

## ✅ Modifications Effectuées

### 1. GameConstants (KISS - Élimination des Magic Values)

**Fichier créé** : `lib/core/constants/game_constants.dart`

Centralise toutes les constantes métier du jeu :

```dart
class GameConstants {
  // IDs spéciaux
  static const String ultimaCardId = 'red_016';  // Carte Ultima
  
  // Règles du jeu
  static const int maxHandSize = 7;
  static const int initialDeckSize = 30;
  static const double maxTension = 100.0;
  
  // Seuils de tension pour débloquer les couleurs
  static const double tensionThresholdBlue = 25.0;
  static const double tensionThresholdYellow = 50.0;
  static const double tensionThresholdRed = 75.0;
  
  // Compteur Ultima
  static const int ultimaMaxTurns = 3;
  
  // Collections Firestore
  static const String gameSessionsCollection = 'game_sessions';
}
```

**Impact** : Plus de `'red_016'` ou `7` hardcodés dans le code → centralisation facile des modifications.

---

### 2. Interfaces Abstraites (SOLID - Dependency Inversion)

**Fichiers créés** dans `lib/core/interfaces/` :

#### ICardService
```dart
abstract class ICardService {
  Future<void> loadAllCards();
  List<GameCard> filterByColor(CardColor color);
  List<GameCard> filterByIds(List<String> ids);
  GameCard? getCardById(String id);
  List<GameCard> get allCards;
  bool get isLoaded;
}
```

#### IGameSessionRepository
```dart
abstract class IGameSessionRepository {
  Future<GameSession> getById(String sessionId);
  Future<void> save(GameSession session);
  Future<void> update(String sessionId, Map<String, dynamic> updates);
  Future<void> delete(String sessionId);
  Stream<GameSession> watchSession(String sessionId);
}
```

#### ITensionService
```dart
abstract class ITensionService {
  bool canPlayCard(GameSession session, String playerId, GameCard card);
  String getEffectiveLevel(double tension);
  double getTensionIncrease(CardColor color);
  bool isColorUnlocked(double tension, CardColor color);
}
```

**Impact** : Les services peuvent être mockés pour les tests, et différentes implémentations peuvent être créées (ex: MockCardService pour les tests).

---

### 3. GameSessionExtensions (KISS - Réduction de la Duplication)

**Fichier créé** : `lib/core/extensions/game_session_extensions.dart`

Simplifie le pattern récurrent `isPlayer1 ? ... : ...` :

```dart
extension GameSessionPlayerExtension on GameSession {
  /// Récupère les données du joueur spécifié
  PlayerData getPlayerData(String playerId) {
    return player1Id == playerId ? player1Data : player2Data!;
  }
  
  /// Récupère les données de l'adversaire
  PlayerData getOpponentData(String playerId) {
    return player1Id == playerId ? player2Data! : player1Data;
  }
  
  /// Met à jour les données d'un joueur et retourne une nouvelle session
  GameSession updatePlayerData(String playerId, PlayerData newData) {
    if (player1Id == playerId) {
      return copyWith(player1Data: newData);
    } else {
      return copyWith(player2Data: newData);
    }
  }
}
```

**Avant** :
```dart
final isPlayer1 = session.player1Id == playerId;
final myData = isPlayer1 ? session.player1Data : session.player2Data!;
// ...modifications...
final updatedSession = isPlayer1 
    ? session.copyWith(player1Data: updatedData) 
    : session.copyWith(player2Data: updatedData);
```

**Après** :
```dart
final myData = session.getPlayerData(playerId);
// ...modifications...
final updatedSession = session.updatePlayerData(playerId, updatedData);
```

---

### 4. MechanicHandler (SOLID - Open/Closed, Strategy Pattern)

**Fichier créé** : `lib/features/game/domain/models/mechanic_handler.dart`

Infrastructure pour le pattern Strategy :

```dart
/// Contexte d'exécution d'une mécanique
class MechanicContext {
  final GameSession session;
  final String playerId;
  final String cardId;
  final GameCard card;
  final int? selectedTier;
  // ...
}

/// Résultat d'exécution d'une mécanique
class MechanicResult {
  final bool success;
  final GameSession? updatedSession;
  final List<PendingAction>? pendingActions;
  final String? errorMessage;
  // ...
}

/// Interface pour les handlers de mécaniques
abstract class IMechanicHandler {
  String get mechanicId;
  Future<MechanicResult> execute(MechanicContext context);
  bool canExecute(MechanicContext context);
}
```

**Impact** : Permet d'ajouter de nouvelles mécaniques sans modifier le code existant (Open/Closed Principle).

---

### 5. Implémentation des Interfaces

#### CardService
- Implémente maintenant `ICardService`
- Nouvelles méthodes : `filterByIds()`, `getCardById()`

#### TensionService
- Implémente maintenant `ITensionService`
- Utilise `GameConstants` au lieu de valeurs hardcodées
- Nouvelle méthode : `isColorUnlocked()`

---

## 🔄 Fichiers Modifiés

| Fichier | Modifications |
|---------|--------------|
| `card_service.dart` | Implémente ICardService, @override, nouvelles méthodes |
| `tension_service.dart` | Implémente ITensionService, utilise GameConstants + Extensions |
| `mechanic_service.dart` | Import Extensions, utilise getPlayerData() |
| `firebase_service.dart` | Import GameConstants, remplace 'red_016' (5 occurrences) |
| `game_actions_mixin.dart` | Import GameConstants + Extensions, utilise getPlayerData() |
| `game_utils_mixin.dart` | Import GameConstants, remplace 'red_016' |
| `game_screen.dart` | Import GameConstants, remplace 'red_016' |
| `app.dart` | Suppression import non utilisé |
| `player.dart` | Suppression import non utilisé |
| `game_dialogs.dart` | Suppression import non utilisé |
| `player_zone_widget.dart` | Suppression import non utilisé |
| `create_game_screen.dart` | Suppression import non utilisé |
| `join_game_screen.dart` | Suppression import non utilisé |
| `waiting_room_screen.dart` | Suppression import non utilisé |

---

## 🚧 Prochaines Étapes

### Court Terme (Priorité 1)
1. **~~Créer GameConstants~~** ✅ FAIT
2. **~~Créer interfaces abstraites~~** ✅ FAIT  
3. **~~Créer GameSessionExtensions~~** ✅ FAIT
4. **~~Remplacer 'red_016' par GameConstants.ultimaCardId~~** ✅ FAIT (13 occurrences)
5. **~~Supprimer imports non utilisés~~** ✅ FAIT (8 fichiers)
6. **Appliquer GameSessionExtensions partout** - ~15 occurrences restantes de `isPlayer1 ? ... : ...`

### Moyen Terme (Priorité 2)
7. **Créer GameSessionRepository** - Implémenter IGameSessionRepository pour découpler FirebaseService
8. **Extraire les handlers de mécaniques** - Utiliser le pattern Strategy créé
9. **Découper FirebaseService** (1512 lignes) en :
   - `AuthService` - Gestion authentification
   - `GameSessionRepository` - CRUD sessions
   - `GameActionsService` - Actions de jeu

10. **Découper GameScreen** (1014 lignes) en widgets plus petits

### Long Terme (Priorité 3)
11. **Ajouter des tests unitaires** utilisant les interfaces mockées
12. **Documentation API** des interfaces
13. **Migrer withOpacity vers withValues** - 341 warnings deprecation

---

## 📁 Nouvelle Structure Core

```
lib/core/
├── constants/
│   ├── colors.dart           # Couleurs UI
│   ├── dimensions.dart       # Dimensions UI
│   ├── animations.dart       # Durées animations
│   └── game_constants.dart   # ✅ NEW - Constantes métier du jeu
│
├── interfaces/               # ✅ NEW - Interfaces abstraites
│   ├── interfaces.dart       # Barrel export
│   ├── i_card_service.dart
│   ├── i_game_session_repository.dart
│   └── i_tension_service.dart
│
├── extensions/               # ✅ NEW - Extensions
│   ├── extensions.dart       # Barrel export
│   └── game_session_extensions.dart
│
├── theme/
│   └── app_theme.dart
└── widgets/
    └── game_button.dart
```

---

## 🎯 Bénéfices Attendus

1. **Testabilité** : Les interfaces permettent de mocker les dépendances
2. **Maintenabilité** : Code centralisé, moins de duplication
3. **Évolutivité** : Nouvelles mécaniques sans toucher au code existant
4. **Lisibilité** : Extensions et constantes nommées
5. **Robustesse** : Moins de risques de bugs liés aux magic values

---

*Dernière mise à jour : Refactoring en cours*
