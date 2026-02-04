import 'package:flutter/material.dart';

/// Bouton réutilisable pour toutes les actions du jeu
class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GameButtonStyle style;
  final double? width;
  final double? height;
  final double? fontSize;

  const GameButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.style = GameButtonStyle.primary,
    this.width,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final isDisabled = onPressed == null;
    final buttonHeight = height ?? 48;
    // Taille du texte = 2/3 de la hauteur du bouton, avec min 10 et max 18
    final responsiveFontSize =
        fontSize ?? (buttonHeight * 0.4).clamp(10.0, 18.0);
    final iconSize = (buttonHeight * 0.45).clamp(14.0, 24.0);

    return SizedBox(
      width: width,
      height: buttonHeight,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDisabled
                      ? [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.10),
                      ]
                      : colors.gradientColors,
            ),
            boxShadow:
                style == GameButtonStyle.flat
                    ? null
                    : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
          ),
          child: Stack(
            children: [
              // Brillance subtile en haut (proportionnelle à la hauteur)
              if (style != GameButtonStyle.flat)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: buttonHeight * 0.4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(
                            alpha: isDisabled ? 0.1 : 0.25,
                          ),
                          Colors.white.withValues(alpha: 0),
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
                              size: iconSize,
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
                            SizedBox(width: responsiveFontSize < 15 ? 4 : 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: responsiveFontSize,
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
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        )
                        : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: responsiveFontSize,
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
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
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
            Colors.blue.withValues(alpha: 0.45),
            Colors.blue.withValues(alpha: 0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.secondary:
        return _ButtonColors(
          gradientColors: [
            Colors.white.withValues(alpha: 0.45),
            Colors.white.withValues(alpha: 0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.success:
        return _ButtonColors(
          gradientColors: [
            Colors.green.withValues(alpha: 0.45),
            Colors.green.withValues(alpha: 0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.danger:
        return _ButtonColors(
          gradientColors: [
            Colors.red.withValues(alpha: 0.45),
            Colors.red.withValues(alpha: 0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.warning:
        return _ButtonColors(
          gradientColors: [
            Colors.orange.withValues(alpha: 0.45),
            Colors.orange.withValues(alpha: 0.30),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.outlined:
        return _ButtonColors(
          gradientColors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.15),
          ],
          foreground: Colors.white,
        );
      case GameButtonStyle.flat:
        return _ButtonColors(
          gradientColors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
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
