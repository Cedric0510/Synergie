# S'Card - Jeu de Cartes Coquin pour Couples 🎴❤️

Un jeu de cartes à collectionner (TCG) sensuel pour couples, développé avec Flutter et Firebase.

## 📖 Concept

S'Card est un jeu de cartes stratégique qui mélange mécaniques de TCG et interactions réelles entre partenaires. Chaque carte possède :
- **Un effet en jeu** : influence la partie (piocher, détruire, dégâts, etc.)
- **Une action IRL** : action à réaliser dans la vraie vie

### Système de Jauge de Tension 🔥

L'innovation principale du jeu : une **jauge de tension individuelle** (0-100%) pour chaque joueur qui détermine quelles cartes peuvent être jouées :

- 🤍 **Blanc** (0-24%) : Actions douces, compliments, regards
- 💙 **Bleu** (25-49%) : Baisers, caresses, déshabillage partiel
- 💛 **Jaune** (50-74%) : Actions sensuelles directes, massages intimes
- ❤️ **Rouge** (75-100%) : Actions très intenses

La jauge augmente de **+5%** quand l'adversaire accepte une action IRL, **+3%** s'il prend les dégâts à la place, **+0%** si l'action est contrée.

## 🎮 Types de Cartes

1. **⚡ Sorts Instantanés** : Jouables à tout moment, permettent de contrer ou répondre
2. **🔮 Rituels** : Jouables uniquement pendant ton tour, effet immédiat
3. **✨ Enchantements** : Restent sur la table, effet continu par tour (+ gain de jauge progressif)

## 🏗️ Architecture Technique

### Stack Technologique

- **Frontend** : Flutter 3.29.2
- **State Management** : Riverpod 2.5+
- **Backend** : Firebase (Firestore + Cloud Functions)
- **Architecture** : Clean Architecture + Feature-first

### Structure du Projet

```
lib/
├── core/
│   ├── constants/          # Couleurs, dimensions, animations
│   ├── theme/              # Thème sombre/sensuel
│   ├── utils/              # Utilitaires
│   └── errors/             # Gestion d'erreurs
├── features/
│   ├── home/               # Écran d'accueil (créer/rejoindre)
│   ├── game/               # Logique de jeu principale
│   │   ├── domain/         # Modèles (Card, Player, GameState)
│   │   ├── data/           # Repositories, datasources
│   │   └── presentation/   # UI (écrans, widgets, providers)
│   └── settings/           # Paramètres (limites soft/medium/hard)
└── widgets/
    └── common/             # Widgets réutilisables
```

## 🚀 Installation et Développement

### Prérequis
- Flutter 3.7.2+
- Android SDK (installé dans `C:\Android`)
- VS Code avec extension Flutter

### Installation

```powershell
# Cloner le repository
cd C:\Dev\Scard

# Installer les dépendances
cd scard_game
flutter pub get

# Générer les fichiers freezed
flutter pub run build_runner build --delete-conflicting-outputs
```

### Lancer l'Application

```powershell
# Sur navigateur (développement rapide)
flutter run -d chrome

# Sur émulateur/appareil Android
flutter run -d android

# Liste des appareils disponibles
flutter devices
```

## 📝 État Actuel du Projet

### ✅ Terminé
- [x] Installation Flutter + Android SDK
- [x] Création du projet avec structure Clean Architecture
- [x] Modèles de domaine (GameCard, Player, GameState, ActiveEnchantment)
- [x] Enums (CardType, CardColor, GamePhase, GameStatus)
- [x] Thème de l'application (sombre/sensuel)
- [x] Constantes (couleurs, dimensions, animations)
- [x] Setup Riverpod pour state management

### 🔜 À Faire
- [ ] Setup Firebase (Firestore + Auth + Functions)
- [ ] Création des 30 cartes de base
- [ ] Écran d'accueil (créer/rejoindre partie)
- [ ] Écran de jeu avec plateau
- [ ] Widgets de cartes avec animations
- [ ] Système de jauge de tension
- [ ] Logique de jeu (jouer carte, réponse, résolution)
- [ ] Multijoueur temps réel via Firestore
- [ ] Dialog d'actions IRL
- [ ] Écran de fin de partie

## 🎨 Direction Artistique

**Thème** : Sensuel, élégant, mature

- **Palette** : Noir profond, rouge passion, violet mystérieux, or
- **Typographie** : Serif pour titres, moderne pour corps
- **Ambiance** : Luxe, mystère, séduction

## 📱 Plateformes Supportées

- ✅ Android
- ✅ iOS (prévu)
- ✅ Web (développement)

---

**Note** : Le jeu est conçu pour des adultes consentants uniquement. Les actions IRL doivent toujours respecter les limites établies entre les partenaires.
