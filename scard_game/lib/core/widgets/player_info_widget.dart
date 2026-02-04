import 'package:flutter/material.dart';

/// Widget affichant les informations d'un joueur
class PlayerInfoWidget extends StatelessWidget {
  final String playerName;
  final int inhibitionPoints;
  final int cardsInHand;
  final int cardsInDeck;
  final bool isCurrentPlayer;
  final VoidCallback? onIncrementPI;
  final VoidCallback? onDecrementPI;
  final VoidCallback? onDrawCard;

  const PlayerInfoWidget({
    super.key,
    required this.playerName,
    required this.inhibitionPoints,
    required this.cardsInHand,
    required this.cardsInDeck,
    this.isCurrentPlayer = false,
    this.onIncrementPI,
    this.onDecrementPI,
    this.onDrawCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isCurrentPlayer
                ? const Color(0xFF27AE60).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCurrentPlayer
                  ? const Color(0xFF27AE60)
                  : Colors.white.withValues(alpha: 0.3),
          width: isCurrentPlayer ? 3 : 2,
        ),
      ),
      child: Row(
        children: [
          // Avatar/Indicateur
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isCurrentPlayer ? const Color(0xFF27AE60) : Colors.grey[400],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // PI avec boutons +/-
                    if (onIncrementPI != null && onDecrementPI != null) ...[
                      _PIControlChip(
                        value: inhibitionPoints,
                        color: _getPIColor(inhibitionPoints),
                        onIncrement: onIncrementPI!,
                        onDecrement: onDecrementPI!,
                      ),
                    ] else
                      _InfoChip(
                        icon: Icons.favorite,
                        label: '$inhibitionPoints PI',
                        color: _getPIColor(inhibitionPoints),
                      ),
                    const SizedBox(width: 8),
                    // Cartes en main
                    _InfoChip(
                      icon: Icons.style,
                      label: '$cardsInHand',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    // Deck avec bouton pioche
                    if (onDrawCard != null)
                      _DeckControlChip(
                        cardsInDeck: cardsInDeck,
                        onDrawCard: onDrawCard!,
                      )
                    else
                      _InfoChip(
                        icon: Icons.layers,
                        label: '$cardsInDeck',
                        color: Colors.grey,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPIColor(int pi) {
    if (pi <= 5) return const Color(0xFFE74C3C); // Rouge
    if (pi <= 10) return const Color(0xFFF39C12); // Orange
    return const Color(0xFF27AE60); // Vert
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour contrôler les PI avec boutons +/-
class _PIControlChip extends StatelessWidget {
  final int value;
  final Color color;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _PIControlChip({
    required this.value,
    required this.color,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton -
          InkWell(
            onTap: onDecrement,
            child: Container(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.remove, size: 14, color: color),
            ),
          ),
          const SizedBox(width: 4),
          // Valeur PI
          Icon(Icons.favorite, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '$value PI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          // Bouton +
          InkWell(
            onTap: onIncrement,
            child: Container(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.add, size: 14, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour le deck avec bouton de pioche
class _DeckControlChip extends StatelessWidget {
  final int cardsInDeck;
  final VoidCallback onDrawCard;

  const _DeckControlChip({required this.cardsInDeck, required this.onDrawCard});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cardsInDeck > 0 ? onDrawCard : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: cardsInDeck > 0 ? Colors.blue : Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.layers,
              size: 12,
              color: cardsInDeck > 0 ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 3),
            Text(
              '$cardsInDeck',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: cardsInDeck > 0 ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.touch_app,
              size: 10,
              color: cardsInDeck > 0 ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
