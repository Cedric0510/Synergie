import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/deck_configuration.dart';

/// Provider pour le service de decks personnalisés
final customDeckServiceProvider = Provider<CustomDeckService>((ref) {
  return CustomDeckService();
});

/// Provider pour charger la configuration du deck actuelle
final currentDeckConfigProvider = FutureProvider<DeckConfiguration>((ref) async {
  final service = ref.watch(customDeckServiceProvider);
  return await service.loadDeckConfiguration();
});

/// Service de gestion des decks personnalisés
/// Gère la sauvegarde et le chargement des configurations de deck
class CustomDeckService {
  static const String _deckConfigKey = 'custom_deck_configuration';

  /// Sauvegarde une configuration de deck
  Future<void> saveDeckConfiguration(DeckConfiguration config) async {
    final prefs = await SharedPreferences.getInstance();
    final json = config.toJson();
    final jsonString = jsonEncode(json);
    await prefs.setString(_deckConfigKey, jsonString);
  }

  /// Charge la configuration du deck
  /// Retourne le deck par défaut si aucune config personnalisée existe
  Future<DeckConfiguration> loadDeckConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_deckConfigKey);

    if (jsonString == null) {
      // Pas de config personnalisée, retourner le deck par défaut
      return DeckConfiguration.defaultDeck();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DeckConfiguration.fromJson(json);
    } catch (e) {
      // En cas d'erreur de parsing, retourner le deck par défaut
      return DeckConfiguration.defaultDeck();
    }
  }

  /// Réinitialise le deck à la configuration par défaut
  Future<void> resetToDefault() async {
    final defaultConfig = DeckConfiguration.defaultDeck();
    await saveDeckConfiguration(defaultConfig);
  }

  /// Supprime la configuration personnalisée
  Future<void> clearCustomConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deckConfigKey);
  }

  /// Vérifie si une configuration personnalisée existe
  Future<bool> hasCustomConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_deckConfigKey);
  }
}
