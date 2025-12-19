/// Sexe du joueur
enum PlayerGender {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case PlayerGender.male:
        return 'Masculin';
      case PlayerGender.female:
        return 'Féminin';
      case PlayerGender.other:
        return 'Autre';
    }
  }

  String get emoji {
    switch (this) {
      case PlayerGender.male:
        return '♂️';
      case PlayerGender.female:
        return '♀️';
      case PlayerGender.other:
        return '⚧️';
    }
  }
}
