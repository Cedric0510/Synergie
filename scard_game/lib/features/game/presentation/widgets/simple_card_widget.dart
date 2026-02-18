import 'package:flutter/material.dart';
import '../../domain/models/game_card.dart';

/// Widget simple pour afficher une carte dans le deck builder
/// Affiche l'illustration de la carte pour une reconnaissance visuelle rapide
class SimpleCardWidget extends StatelessWidget {
  final GameCard card;

  const SimpleCardWidget({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _getBorderColor(), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: card.imageUrl != null
            ? Image.asset(
                card.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // En cas d'erreur de chargement, afficher une icône
                  return _buildFallbackIcon();
                },
              )
            : _buildFallbackIcon(),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: _getCardColor(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCardIcon(),
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              card.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    switch (card.color.name) {
      case 'white':
        return Colors.grey.shade400;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.amber;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getCardColor() {
    switch (card.color.name) {
      case 'white':
        return Colors.grey.shade300;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.amber;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCardIcon() {
    if (card.isEnchantment) {
      return Icons.auto_awesome;
    }
    switch (card.type) {
      case 'ritual':
        return Icons.favorite;
      case 'instant':
        return Icons.flash_on;
      default:
        return Icons.style;
    }
  }
}
