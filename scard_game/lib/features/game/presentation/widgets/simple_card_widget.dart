import 'package:flutter/material.dart';
import '../../domain/models/game_card.dart';

/// Widget simple pour afficher une carte dans le deck builder
/// Version miniature sans interactions
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
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône selon le type
          Icon(
            _getCardIcon(),
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 4),
          // Nom de la carte
          Text(
            card.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
