# Multiplayer Smoke Test

Derniere mise a jour: 2026-03-31

Objectif: verifier rapidement que le flux multijoueur Firebase (Auth + Firestore) fonctionne apres refactor.

## Pre-requis

- Deux instances de l'app (deux navigateurs ou deux appareils/emulateurs).
- Projet Firebase configure (`firebase_options.dart`, regles deployees).
- Collection Firestore `game_sessions` accessible selon `firestore.rules`.

## Parcours de test

1. Joueur A ouvre l'app.
2. Joueur A cree une partie avec un nom + genre.
3. Verifier qu'un code de partie est affiche (6 caracteres).
4. Joueur B ouvre l'app.
5. Joueur B rejoint la partie avec le code.
6. Verifier que les deux joueurs apparaissent dans la salle d'attente.
7. Les deux joueurs cliquent "Pret".
8. Verifier demarrage de partie et attribution du joueur courant.
9. Verifier distribution des mains/decks pour les deux joueurs.
10. Jouer 1 carte cote Joueur A et valider l'action.
11. Verifier propagation en temps reel cote Joueur B (pile/phase).
12. Jouer 1 reponse cote Joueur B (phase response).
13. Verifier resolution puis passage de phase/tour.
14. Forcer une action simple PI/Tension (si disponible UI) et verifier synchro.
15. Quitter/revenir sur une instance et verifier reprise de session sans corruption.

## Critere de succes

- Aucune erreur bloquante UI.
- Aucune erreur Firestore "permission-denied".
- Synchronisation etat en temps reel entre A et B.
- Flux create -> join -> ready -> play -> response -> resolution fonctionnel.

## En cas d'echec

- Capturer l'etape exacte et le message d'erreur.
- Verifier dans Firestore le document `game_sessions/<code>`.
- Revalider localement:
  - `flutter analyze`
  - `flutter test`
  - `dart run tools/validate_cards_json.dart`
