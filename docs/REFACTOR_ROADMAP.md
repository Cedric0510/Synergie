# Refactor Roadmap (3 Phases)

Ce plan vise a stabiliser le projet sans regression de gameplay, puis a reduire la dette technique de facon incrementale.

## Phase 1 - Stabilisation (priorite immediate)

Objectif: fiabiliser le flux de partie et remettre une base testable.

1. Verrouiller le flux Firebase de base
- Regles Firestore compatibles avec le join flow (`player2`).
- Verification manuelle: create -> join -> ready -> game.
- Fichiers:
  - `scard_game/firestore.rules`

2. Corriger les casses de tests bloquantes
- Migrer les tests aux signatures de services actuelles.
- Fichiers:
  - `scard_game/test/deck_service_test.dart`

3. Assainir la source de verite des cartes
- JSON homogene (structure stable, tri, chemins image coherents).
- Ne pas changer les IDs tant que la migration deck/config n'est pas terminee.
- Fichier:
  - `scard_game/assets/data/cards.json`

4. Checks de sortie de phase
- `flutter test`
- `flutter analyze`

---

## Phase 2 - Service Layer Clean-up

Objectif: supprimer la duplication `FirebaseService` vs services specialises.

1. `FirebaseService` retire du runtime (termine)
- Les appels actifs sont deplaces vers:
  - `GameSessionService`
  - `PlayerService`
  - `TurnService`
  - `GameplayActionService`
  - `SessionStateService`
- Le fichier legacy `firebase_service.dart` est supprime.

2. Unifier les conventions metier
- Cles de status lock: standard unique (`pi_locked`, `tension_locked` ou equivalent).
- Une seule source pour les valeurs de tension par couleur (`GameConstants` + `TensionService`).
- Initial PI / deck size / compteur Ultima coherents entre constants/model/tests (termine).

3. Eliminer les doubles implementations
- `executePendingActions` duplique.
- Dialogues de reponse/validation partages dans un seul point.

4. Checks de sortie de phase
- Parcours complet d'une partie a 2 joueurs.
- Tests unitaires services critiques (tension, turn, validation).

---

## Phase 3 - Domain + UI Modularisation

Objectif: rendre le coeur de jeu plus simple a maintenir.

1. Clarifier les modeles actifs vs historiques
- Conserver `GameSession`/`PlayerData` comme modele runtime.
- Decommissionner `GameState`/`Player` si non utilises.

2. Decouper `GameScreen` en orchestration + composants
- Garder `GameScreen` comme assembleur.
- Extraire le flux de tour/validation dans un coordinator dedie (testable hors widget).

3. Normaliser la data cards
- Eventuelle migration IDs/couleurs (ex: prefix ID vs `color`) uniquement avec plan de migration deck.
- Outil de validation JSON (script CI) pour eviter les derives futures.

4. Checks de sortie de phase
- Tests widget critiques (drag/drop, validation, enchantements, victoire).
- Lint propre sur les modules refactores.

---

## Regles de securite de refacto

1. Une seule zone de changement a la fois (petits PR).
2. Aucune modification destructive des IDs de cartes sans migration explicite.
3. Toujours valider `create/join/play` apres changement des services.
