import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../gallery/presentation/screens/gallery_screen.dart';
import '../../../game/presentation/screens/deck_builder_screen.dart';
import '../../../matchmaking/presentation/screens/create_game_screen.dart';
import '../../../matchmaking/presentation/screens/join_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _titleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Initialiser la vidéo uniquement sur mobile (pas sur web)
    if (!kIsWeb) {
      _initializeVideo();
    }

    // Démarrer l'animation du titre après un court délai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/videos/Intro.mp4');
      await _videoController!.initialize();

      if (mounted) {
        setState(() {
          _videoInitialized = true;
        });

        // Lancer la vidéo
        await _videoController!.play();

        // Écouter la fin de la vidéo pour la figer sur la dernière frame
        _videoController!.addListener(() {
          if (_videoController!.value.position >=
              _videoController!.value.duration) {
            _videoController!.pause();
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur initialisation vidéo: $e');
      if (mounted) {
        setState(() {
          _videoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Vidéo sur mobile, image sur web
          Positioned.fill(
            child:
                kIsWeb
                    ? Image.asset(
                      'assets/data/intro.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )
                    : _videoError
                    ? Image.asset(
                      'assets/data/intro.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )
                    : _videoInitialized && _videoController != null
                    ? FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                    : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
          ),

          // Overlay gradient pour assurer la lisibilité
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Titre animé en haut
          AnimatedBuilder(
            animation: _titleAnimation,
            builder: (context, child) {
              final screenHeight = MediaQuery.of(context).size.height;
              final isMobile = MediaQuery.of(context).size.width < 600;
              final mobileAdjustment = isMobile ? screenHeight * 0.2 : 0;
              final targetPosition =
                  MediaQuery.of(context).padding.top + 40 - mobileAdjustment;
              return Positioned(
                top: -200 + (targetPosition + 200) * _titleAnimation.value,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _titleAnimation.value,
                  child: _buildTitle(theme),
                ),
              );
            },
          ),

          // Contenu par-dessus
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),

                // Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Un jeu sensuel pour pimenter vos soirées',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.5,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Boutons
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24 : 48,
                  ),
                  child: Column(
                    children: [
                      _MenuButton(
                        label: 'Créer une partie',
                        icon: Icons.favorite_border,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.white.withValues(alpha: 0.9),
                          ],
                        ),
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CreateGameScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _MenuButton(
                        label: 'Rejoindre une partie',
                        icon: Icons.people_outline,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.85),
                            Colors.white.withValues(alpha: 0.8),
                          ],
                        ),
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const JoinGameScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _MenuButton(
                        label: 'Mon Deck',
                        icon: Icons.style,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.75),
                            Colors.white.withValues(alpha: 0.7),
                          ],
                        ),
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DeckBuilderScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      _MenuButton(
                        label: 'Galerie',
                        icon: Icons.photo_library_outlined,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.25),
                          ],
                        ),
                        textColor: Colors.white,
                        isOutlined: true,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const GalleryScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget titre avec image
  Widget _buildTitle(ThemeData theme) {
    return Center(
      child: Image.asset(
        'assets/data/titre.png',
        width: 1200,
        height: 480,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Gradient gradient;
  final Color textColor;
  final bool isOutlined;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.gradient,
    required this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          // Ombre portée
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corps principal transparent
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: isOutlined ? 0.15 : 0.35),
                  Colors.white.withValues(alpha: isOutlined ? 0.08 : 0.20),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border:
                  isOutlined
                      ? Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      )
                      : null,
            ),
          ),

          // Reflet/brillance en haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 25,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // Contenu
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 26, color: textColor),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: textColor,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
