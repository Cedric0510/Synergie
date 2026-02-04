import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/interfaces/i_auth_service.dart';

/// Provider pour le service d'authentification
final authServiceProvider = Provider<IAuthService>((ref) {
  return AuthService();
});

/// Service d'authentification Firebase
/// Gère la connexion anonyme des joueurs (Principe S - Single Responsibility)
class AuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Connexion anonyme
  /// Retourne l'ID de l'utilisateur connecté
  @override
  Future<String> signInAnonymously() async {
    try {
      // Vérifier si l'utilisateur est déjà connecté
      if (_auth.currentUser != null) {
        return _auth.currentUser!.uid;
      }

      // Sinon, créer une nouvelle connexion anonyme
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user!.uid;
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  /// Récupère l'ID de l'utilisateur actuel (null si non connecté)
  @override
  String? get currentUserId => _auth.currentUser?.uid;

  /// Vérifie si un utilisateur est connecté
  @override
  bool get isSignedIn => _auth.currentUser != null;

  /// Déconnexion
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
