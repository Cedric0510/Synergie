import 'package:flutter/material.dart';
import '../../domain/models/game_card.dart';
import '../../domain/enums/card_color.dart' as game;
import '../../domain/enums/card_type.dart';
import '../../domain/enums/card_level.dart';

/// Widget pour afficher une carte de jeu au format standard
class CardWidget extends StatelessWidget {
  final GameCard card;
  final double width;
  final double height;
  final bool compact;
  final bool showPreviewOnHover;
  final CardLevel? currentLevel;

  const CardWidget({
    super.key,
    required this.card,
    this.width = 180,
    this.height = 280,
    this.compact = false,
    this.showPreviewOnHover = false,
    this.currentLevel,
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
            color: const Color(0xFFF9F9FB),
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
                currentLevel: currentLevel,
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

  /// Layout complet avec nom + image + effets par palier
  Widget _buildFullLayout() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          _buildTitleSection(),
          _buildImageSection(),
          _buildTierEffectsSection(),
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

  /// Bandeau nom de la carte
  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: _getBorderColor(card.color)),
      child: Text(
        card.name,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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

  /// Tiers inférieur : Effets par palier (blanc/bleu/jaune/rouge)
  Widget _buildTierEffectsSection() {
    final effects = _parseTierEffects();

    return Expanded(
      flex: 10,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(color: Colors.grey[50]),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final effect in effects) ...[
                _buildTierBubble(effect),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierBubble(_TierEffect effect) {
    final isEnabled = _isTierEnabled(effect.label);
    final isWhiteTier = effect.label.trim().toLowerCase() == 'blanc';
    final border =
        isEnabled ? effect.color : Colors.grey.withOpacity(0.85);
    final background =
        isEnabled
            ? (isWhiteTier
                ? const Color(0xFF5E5E5E)
                : effect.color.withOpacity(0.08))
            : Colors.black.withOpacity(0.12);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border.withOpacity(0.7), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 3, right: 6),
            decoration: BoxDecoration(
              color:
                  isEnabled
                      ? (isWhiteTier ? Colors.white : border)
                      : Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  if (effect.label.isNotEmpty)
                    TextSpan(
                      text: '${effect.label}: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            isEnabled
                                ? (isWhiteTier ? Colors.white : border)
                                : Colors.grey[600],
                      ),
                    ),
                  TextSpan(
                    text: effect.text,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.25,
                      color:
                          isEnabled
                              ? (isWhiteTier ? Colors.white : Colors.black87)
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_TierEffect> _parseTierEffects() {
    final raw = card.gameEffect;
    final lines =
        raw
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

    final colorByLabel = <String, Color>{
      'blanc': Colors.grey[700]!,
      'bleu': const Color(0xFF1E88E5),
      'jaune': const Color(0xFFF9A825),
      'rouge': const Color(0xFFE53935),
    };

    final effects = <_TierEffect>[];
    for (final line in lines) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        final label = parts.first.trim();
        final text = line.substring(line.indexOf(':') + 1).trim();
        final key = label.toLowerCase();
        final color = colorByLabel[key] ?? Colors.black87;
        effects.add(_TierEffect(label: label, text: text, color: color));
      } else {
        effects.add(
          _TierEffect(label: '', text: line.trim(), color: Colors.black87),
        );
      }
    }

    if (effects.isEmpty) {
      effects.add(
        _TierEffect(label: '', text: card.gameEffect, color: Colors.black87),
      );
    }

    return effects;
  }

  bool _isTierEnabled(String label) {
    if (currentLevel == null) return true;
    if (label.isEmpty) return true;
    final tier = _labelToLevel(label);
    if (tier == null) return true;
    return _levelRank(tier) <= _levelRank(currentLevel!);
  }

  CardLevel? _labelToLevel(String label) {
    switch (label.trim().toLowerCase()) {
      case 'blanc':
        return CardLevel.white;
      case 'bleu':
        return CardLevel.blue;
      case 'jaune':
        return CardLevel.yellow;
      case 'rouge':
        return CardLevel.red;
    }
    return null;
  }

  int _levelRank(CardLevel level) {
    switch (level) {
      case CardLevel.white:
        return 0;
      case CardLevel.blue:
        return 1;
      case CardLevel.yellow:
        return 2;
      case CardLevel.red:
        return 3;
    }
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

class _TierEffect {
  final String label;
  final String text;
  final Color color;

  const _TierEffect({
    required this.label,
    required this.text,
    required this.color,
  });
}
