# Technical Debt Audit (Prioritized)

Date: 2026-03-31

This audit lists concrete risks seen in the current codebase and a PR-by-PR execution order.

## P0 - Functional coherence (do first)

1. Unify tension values in one source of truth
- Current state:
- `GameActionsMixin` uses hardcoded values `5/8/12/15`.
- `GameConstants.tensionByCardColor` is `5/10/15/20`.
- `TensionService.getTensionIncrease()` reads `GameConstants.tensionByCardColor`.
- Risk: hidden behavior drift when a caller uses `TensionService.getTensionIncrease()`.
- Files:
- `scard_game/lib/features/game/presentation/screens/mixins/game_actions_mixin.dart`
- `scard_game/lib/core/constants/game_constants.dart`
- `scard_game/lib/features/game/data/services/tension_service.dart`

2. Freeze and document card identity contract (`id` vs `color`)
- Current state:
- `blue_005` and `blue_006` have `color: white`.
- Deck logic and default config rely on ID prefixes.
- Risk: accidental break during future JSON cleanup or deck migration.
- Files:
- `scard_game/assets/data/cards.json`
- `scard_game/lib/features/game/domain/models/deck_configuration.dart`
- `scard_game/tools/validate_cards_json.dart`

3. Tighten Firestore join update scope
- Current state:
- join rule allows a joining user to update session when `player2Id == null`.
- It currently protects `player1Id` and `sessionId` but does not explicitly pin all mutable fields during join update.
- Risk: unexpected field mutation at join time.
- Files:
- `scard_game/firestore.rules`

## P1 - Architecture simplification

4. Migration away from `FirebaseService` (DONE - 2026-03-31)
- Runtime now relies on specialized services:
  - `GameSessionService`
  - `PlayerService`
  - `TurnService`
  - `GameplayActionService`
  - `SessionStateService`
- `firebase_service.dart` removed.

5. Replace `ignore_for_file` workaround with dialog orchestration split
- Current state:
- `GameValidationMixin` now has `// ignore_for_file: use_build_context_synchronously`.
- Risk: future unsafe UI async changes can slip in.
- Files:
- `scard_game/lib/features/game/presentation/screens/mixins/game_validation_mixin.dart`

## P2 - Domain cleanup and maintainability

6. Remove or archive legacy domain models not used in runtime flow
- Current state:
- `GameState` / `Player` models are generated but not used by gameplay flow.
- Risk: confusion and wrong model usage by future contributors.
- Files:
- `scard_game/lib/features/game/domain/models/game_state.dart`
- `scard_game/lib/features/game/domain/models/player.dart`

7. Align constants that look stale against runtime logic
- Candidates:
- `initialPI` vs `PlayerData` defaults
- `deckSize` vs actual deck builder constraints (25 cards)
- `ultimaMaxCount` vs turn win logic
- Risk: tests may still pass while design intent drifts.
- Files:
- `scard_game/lib/core/constants/game_constants.dart`
- `scard_game/lib/features/game/domain/models/player_data.dart`
- `scard_game/lib/features/game/data/services/turn_service.dart`
- `scard_game/lib/features/game/domain/models/deck_configuration.dart`
- Status: DONE (constants aligned and usages updated).

## Recommended PR order

PR-1: Tension coherence + direct tests of real `TensionService`.

PR-2: Card identity contract decision (`id`/`color`) + explicit guardrails in validator and tests.

PR-3: Firestore join rule hardening.

PR-4: Incremental replacement of `FirebaseService` calls in mixins with specialized services.

PR-5: Remove `ignore_for_file` by extracting a dedicated validation dialog coordinator.

PR-6: Domain and constants cleanup (legacy model removal + constants alignment).

## Definition of done per PR

- `flutter analyze` is clean.
- `flutter test` is green.
- `dart run tools/validate_cards_json.dart` stays green.
- `create -> join -> distribution -> game` manual smoke flow validated.
