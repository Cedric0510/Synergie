import 'package:flutter/material.dart';

/// Bouton réutilisable pour toutes les actions du jeu
class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GameButtonStyle style;
  final double? width;
  final double? height;

  const GameButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.style = GameButtonStyle.primary,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final isDisabled = onPressed == null;

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDisabled
                      ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.10),
                      ]
                      : colors.gradientColors,
            ),
            boxShadow:
                style == GameButtonStyle.flat
                    ? null
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
          ),
          child: Stack(
            children: [
              // Brillance en haut
              if (style != GameButtonStyle.flat)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(isDisabled ? 0.2 : 0.5),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              Center(
                child:
                    icon != null
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 20,
                              color:
                                  isDisabled
                                      ? Colors.white38
                                      : colors.foreground,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDisabled
                                        ? Colors.white38
                                        : colors.foreground,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        )
                        : Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color:
                                isDisabled ? Colors.white38 : colors.foreground,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ButtonColors _getColors() {
    switch (style) {
      case GameButtonStyle.primary:
        return _ButtonColors(
          gradientColors: [
            Colors.blue.withOpacity(0.45),
            Colors.blue.withOpacity(0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.secondary:
        return _ButtonColors(
          gradientColors: [
            Colors.white.withOpacity(0.45),
            Colors.white.withOpacity(0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.success:
        return _ButtonColors(
          gradientColors: [
            Colors.green.withOpacity(0.45),
            Colors.green.withOpacity(0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.danger:
        return _ButtonColors(
          gradientColors: [
            Colors.red.withOpacity(0.45),
            Colors.red.withOpacity(0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.warning:
        return _ButtonColors(
          gradientColors: [
            Colors.orange.withOpacity(0.45),
            Colors.orange.withOpacity(0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.outlined:
        return _ButtonColors(
          gradientColors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.flat:
        return _ButtonColors(
          gradientColors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          foreground: Colors.white,
        );
    }
  }
}

enum GameButtonStyle {
  primary, // Bleu (action principale)
  secondary, // Blanc (action secondaire)
  success, // Vert (validation)
  danger, // Rouge (annulation/sacrifice)
  warning, // Orange (attention)
  outlined, // Contour uniquement
  flat, // Transparent
}

class _ButtonColors {
  final List<Color> gradientColors;
  final Color foreground;

  _ButtonColors({required this.gradientColors, required this.foreground});
}
