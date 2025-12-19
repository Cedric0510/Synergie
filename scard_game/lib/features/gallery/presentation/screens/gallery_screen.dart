import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../game/data/services/card_service.dart';
import '../../../game/domain/enums/card_color.dart' as game;
import '../../../game/domain/models/game_card.dart';
import '../../../game/presentation/widgets/card_widget.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsByColorAsync = ref.watch(cardsByColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie de cartes'),
        backgroundColor: const Color(0xFF2980B9),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6DD5FA), // Bleu clair
              const Color(0xFF2980B9), // Bleu moyen
              const Color(0xFF8E44AD).withOpacity(0.7), // Violet doux
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: cardsByColorAsync.when(
          data: (cardsByColor) => _buildGallery(context, cardsByColor),
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('$error'),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildGallery(
    BuildContext context,
    Map<game.CardColor, List<GameCard>> cardsByColor,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cartes blanches
        if (cardsByColor[game.CardColor.white]?.isNotEmpty ?? false)
          _buildColorSection(
            context,
            'Cartes Blanches',
            cardsByColor[game.CardColor.white]!,
            Colors.grey[300]!,
          ),

        const SizedBox(height: 24),

        // Cartes bleues
        if (cardsByColor[game.CardColor.blue]?.isNotEmpty ?? false)
          _buildColorSection(
            context,
            'Cartes Bleues',
            cardsByColor[game.CardColor.blue]!,
            const Color(0xFF2196F3),
          ),

        const SizedBox(height: 24),

        // Cartes jaunes
        if (cardsByColor[game.CardColor.yellow]?.isNotEmpty ?? false)
          _buildColorSection(
            context,
            'Cartes Jaunes',
            cardsByColor[game.CardColor.yellow]!,
            const Color(0xFFFFC107),
          ),

        const SizedBox(height: 24),

        // Cartes rouges
        if (cardsByColor[game.CardColor.red]?.isNotEmpty ?? false)
          _buildColorSection(
            context,
            'Cartes Rouges',
            cardsByColor[game.CardColor.red]!,
            const Color(0xFFF44336),
          ),

        const SizedBox(height: 24),

        // Cartes vertes (Négociations)
        if (cardsByColor[game.CardColor.green]?.isNotEmpty ?? false)
          _buildColorSection(
            context,
            'Cartes Vertes',
            cardsByColor[game.CardColor.green]!,
            const Color(0xFF4CAF50),
          ),
      ],
    );
  }

  Widget _buildColorSection(
    BuildContext context,
    String title,
    List<GameCard> cards,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de la section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            children: [
              Icon(Icons.style, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              Text(
                '${cards.length} cartes',
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Grille de cartes (3 colonnes)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.64, // Format carte standard
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return GestureDetector(
              onTap: () => _showCardDetails(context, card),
              child: CardWidget(card: card, width: 120, height: 180),
            );
          },
        ),
      ],
    );
  }

  /// Affiche les détails d'une carte dans un dialog
  void _showCardDetails(BuildContext context, GameCard card) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CardWidget(card: card, width: 240, height: 360),
                  const SizedBox(height: 16),
                  Text(
                    card.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
