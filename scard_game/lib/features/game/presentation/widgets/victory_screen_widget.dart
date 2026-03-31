import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/game_constants.dart';
import '../../domain/models/game_session.dart';

/// Widget d'écran de victoire Ultima avec vidéo aléatoire
class VictoryScreenWidget extends StatefulWidget {
  final GameSession session;
  final String playerId;

  const VictoryScreenWidget({
    super.key,
    required this.session,
    required this.playerId,
  });

  @override
  State<VictoryScreenWidget> createState() => _VictoryScreenWidgetState();
}

class _VictoryScreenWidgetState extends State<VictoryScreenWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (!_isVideoPlaying && _videoController == null) {
      _isVideoPlaying = true;
      final random = Random();
      final videoNumber = random.nextInt(5) + 1; // 1 à 5
      final videoPath = 'assets/videos/Victory$videoNumber.mp4';

      _videoController = VideoPlayerController.asset(videoPath)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController!.play();
          }
        });

      // Passer automatiquement à l'écran de victoire après la vidéo
      _videoController!.addListener(() {
        if (_videoController!.value.position ==
            _videoController!.value.duration) {
          if (mounted) {
            setState(() {
              _videoController?.dispose();
              _videoController = null;
            });
          }
        }
      });
    }
  }

  void _skipVideo() {
    setState(() {
      _videoController?.dispose();
      _videoController = null;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWinner = widget.session.winnerId == widget.playerId;

    // Si la vidéo est en cours de lecture
    if (_videoController != null && _videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Vidéo en plein écran
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),

            // Bouton "Passer" en haut à droite
            Positioned(
              top: 40,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: _skipVideo,
                icon: const Icon(Icons.skip_next),
                label: const Text('Passer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Écran de victoire classique (après la vidéo ou si erreur)
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              isWinner
                  ? [
                    const Color(0xFFFFD700), // Or
                    const Color(0xFFFF6B6B), // Rouge rosé
                  ]
                  : [
                    const Color(0xFF2C3E50), // Gris foncé
                    const Color(0xFF34495E), // Gris bleuté
                  ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône
                Icon(
                  isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 120,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Titre
                Text(
                  isWinner ? '🎉 VICTOIRE ! 🎉' : '😔 DÉFAITE',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Message Ultima
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isWinner
                            ? 'Vous avez conservé Ultima pendant ${GameConstants.ultimaMaxCount} tours !'
                            : 'Votre adversaire a conservé Ultima pendant ${GameConstants.ultimaMaxCount} tours',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isWinner
                            ? 'Votre adversaire vous doit un orgasme\n(vous d\'abord) 💕'
                            : 'Vous devez un orgasme à votre adversaire\n(lui/elle d\'abord) 💕',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton retour
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home, size: 24),
                  label: const Text(
                    'Retour à l\'accueil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
