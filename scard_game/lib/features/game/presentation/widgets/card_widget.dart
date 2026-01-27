import 'package:flutter/material.dart';
import '../../domain/models/game_card.dart';
import '../../domain/enums/card_color.dart' as game;
import '../../domain/enums/card_type.dart';

/// Widget pour afficher une carte de jeu au format standard
class CardWidget extends StatelessWidget {
  final GameCard card;
  final double width;
  final double height;
  final bool compact;
  final bool showPreviewOnHover;

  const CardWidget({
    super.key,
    required this.card,
    this.width = 180,
    this.height = 280,
    this.compact = false,
    this.showPreviewOnHover = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor(card.color);

    final cardWidget = SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 1 / 1.55,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: compact ? _buildCompactLayout() : _buildFullLayout(),
        ),
      ),
    );

    if (showPreviewOnHover) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          richMessage: WidgetSpan(
            child: Material(
              color: Colors.transparent,
              child: CardWidget(
                card: card,
                width: 280,
                height: 440,
                compact: false,
              ),
            ),
          ),
          decoration: const BoxDecoration(),
          padding: EdgeInsets.zero,
          preferBelow: false,
          verticalOffset: 20,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }

  /// Layout complet avec tous les détails
  Widget _buildFullLayout() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          // TIERS 1 : Image (1/3)
          _buildImageSection(),

          // TIERS 2 : Coût de lancement (1/3)
          _buildCostSection(),

          // TIERS 3 : Effets (1/3)
          _buildEffectsSection(),
        ],
      ),
    );
  }

  /// Layout compact pour le jeu (image + nom + type)
  Widget _buildCompactLayout() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Image principale (70% de la hauteur)
              SizedBox(
                height: constraints.maxHeight * 0.70,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child:
                        card.imageUrl != null
                            ? Image.asset(card.imageUrl!, fit: BoxFit.cover)
                            : const Icon(
                              Icons.image_not_supported,
                              size: 30,
                              color: Colors.grey,
                            ),
                  ),
                ),
              ),
              // Nom de la carte (20% de la hauteur)
              Container(
                height: constraints.maxHeight * 0.20,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(color: _getBorderColor(card.color)),
                child: Center(
                  child: Text(
                    card.name,
                    style: TextStyle(
                      fontSize: (constraints.maxHeight * 0.08).clamp(8.0, 12.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Badge type (10% de la hauteur)
              Container(
                height: constraints.maxHeight * 0.10,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    _getCardTypeLabel(card.type),
                    style: TextStyle(
                      fontSize: (constraints.maxHeight * 0.06).clamp(6.0, 10.0),
                      fontWeight: FontWeight.w600,
                      color: _getBorderColor(card.color),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Tiers supérieur : Image de la carte
  Widget _buildImageSection() {
    return Expanded(
      flex: 11,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child:
              card.imageUrl != null
                  ? Image.asset(card.imageUrl!, fit: BoxFit.cover)
                  : const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
        ),
      ),
    );
  }

  /// Tiers central : Coût de lancement
  Widget _buildCostSection() {
    return Expanded(
      flex: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Container(
          decoration: BoxDecoration(
            color: _getBorderColor(card.color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getBorderColor(card.color), width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _getBorderColor(card.color),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  card.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Coût',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: _getBorderColor(card.color),
                ),
              ),
              Flexible(
                child: Text(
                  card.launcherCost,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1565C0),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tiers inférieur : Effets (en jeu + IRL)
  Widget _buildEffectsSection() {
    return Expanded(
      flex: 11,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          color: Colors.grey[50],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Effet en jeu
                    Text(
                      'En jeu :',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      card.gameEffect,
                      style: const TextStyle(
                        fontSize: 9,
                        height: 1.1,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Effet IRL
                    if (card.targetEffect != null) ...[
                      Text(
                        'IRL :',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        card.targetEffect!,
                        style: const TextStyle(
                          fontSize: 9,
                          height: 1.1,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Badge type en bas à gauche
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: _getBorderColor(card.color),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _getCardTypeLabel(card.type),
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Récupère la couleur de bordure selon la couleur de la carte
  Color _getBorderColor(game.CardColor color) {
    switch (color) {
      case game.CardColor.white:
        return Colors.grey[600]!; // Assombri pour meilleure lisibilité
      case game.CardColor.blue:
        return const Color(0xFF2196F3);
      case game.CardColor.yellow:
        return const Color(0xFFFFC107);
      case game.CardColor.red:
        return const Color(0xFFF44336);
      case game.CardColor.green:
        return const Color(0xFF4CAF50);
    }
  }

  /// Récupère le label du type de carte
  String _getCardTypeLabel(CardType type) {
    switch (type) {
      case CardType.instant:
        return 'Éphémère';
      case CardType.ritual:
        return 'Rituel';
      case CardType.enchantment:
        return 'Enchantement';
    }
  }
}
