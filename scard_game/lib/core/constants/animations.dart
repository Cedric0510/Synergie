/// Durées pour les animations
class AnimationDurations {
  AnimationDurations._();

  // === DURÉES STANDARDS ===
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // === ANIMATIONS SPÉCIFIQUES ===
  static const Duration cardFlip = Duration(milliseconds: 400);
  static const Duration cardSlide = Duration(milliseconds: 300);
  static const Duration tensionGaugeUpdate = Duration(milliseconds: 500);
  static const Duration dialogFade = Duration(milliseconds: 250);

  // === TIMERS DE JEU ===
  static const Duration responseTimer = Duration(seconds: 15);
  static const Duration turnTransition = Duration(seconds: 2);
}
