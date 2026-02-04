/// Interface pour le service d'authentification
/// Permet de découpler l'authentification du reste de l'application (Principe D - Dependency Inversion)
abstract class IAuthService {
  /// Connexion anonyme
  /// Retourne l'ID de l'utilisateur connecté
  Future<String> signInAnonymously();

  /// Récupère l'ID de l'utilisateur actuel (null si non connecté)
  String? get currentUserId;

  /// Vérifie si un utilisateur est connecté
  bool get isSignedIn;

  /// Déconnexion
  Future<void> signOut();
}
