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

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          elevation: style == GameButtonStyle.flat ? 0 : 4,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                style == GameButtonStyle.outlined
                    ? BorderSide(color: colors.background, width: 2)
                    : BorderSide.none,
          ),
        ),
        child:
            icon != null
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                )
                : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
      ),
    );
  }

  _ButtonColors _getColors() {
    switch (style) {
      case GameButtonStyle.primary:
        return _ButtonColors(
          background: const Color(0xFF2980B9),
          foreground: Colors.white,
        );
      case GameButtonStyle.secondary:
        return _ButtonColors(
          background: Colors.white,
          foreground: const Color(0xFF2980B9),
        );
      case GameButtonStyle.success:
        return _ButtonColors(
          background: const Color(0xFF27AE60),
          foreground: Colors.white,
        );
      case GameButtonStyle.danger:
        return _ButtonColors(
          background: const Color(0xFFE74C3C),
          foreground: Colors.white,
        );
      case GameButtonStyle.warning:
        return _ButtonColors(
          background: const Color(0xFFF39C12),
          foreground: Colors.white,
        );
      case GameButtonStyle.outlined:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: const Color(0xFF2980B9),
        );
      case GameButtonStyle.flat:
        return _ButtonColors(
          background: Colors.white.withOpacity(0.2),
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
  final Color background;
  final Color foreground;

  _ButtonColors({required this.background, required this.foreground});
}
