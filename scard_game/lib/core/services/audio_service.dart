import 'package:flutter/services.dart';

/// Service de gestion des effets sonores
class AudioService {
  /// Joue un son de notification système (beep natif)
  static Future<void> playTimerFinished() async {
    try {
      // Utilise le son système natif (vibration + click)
      await SystemSound.play(SystemSoundType.alert);
      // Double beep pour plus de clarté
      await Future.delayed(const Duration(milliseconds: 200));
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Fallback silencieux si le son échoue (pas critique)
      // ignore: avoid_print
      print('Erreur lecture son timer: $e');
    }
  }
}
