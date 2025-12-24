import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/watching_entry.dart';
import '../screens/anime_details_page.dart';
import 'expressive_image.dart';
import '../theme/expressive_theme.dart';
import 'grain_overlay.dart';

class WatchingCard extends StatefulWidget {
  final WatchingEntry entry;
  final int progress;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;
  final double? width;
  final double? height;
  final String? heroPrefix;
  final double vibeScore;

  const WatchingCard({
    super.key,
    required this.entry,
    required this.progress,
    required this.onIncrement,
    this.onDecrement,
    this.width,
    this.height,
    this.heroPrefix,
    this.vibeScore = 0.0,
  });

  @override
  State<WatchingCard> createState() => _WatchingCardState();
}

class _WatchingCardState extends State<WatchingCard> {
  late ConfettiController _confettiController;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalEpisodes = widget.entry.anime.episodes ?? 12; // fallback
    final progressFraction = (widget.progress / totalEpisodes).clamp(0.0, 1.0);
    final hasNext = widget.progress < totalEpisodes;

    final vibe = VibeColors.fromScore(
      widget.vibeScore,
      widget.entry.anime.parsedColor,
    );

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () async {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) setState(() => _isPressed = false);
          await Future.delayed(const Duration(milliseconds: 50));
          if (!context.mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnimeDetailsPage(anime: widget.entry.anime),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutQuad,
          transform: Matrix4.translationValues(
            _isPressed ? vibe.shadowOffset.dx : 0,
            _isPressed ? vibe.shadowOffset.dy : 0,
            0,
          ),
          width: widget.width ?? 280,
          height: widget.height,
          margin: const EdgeInsets.only(bottom: 12, right: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(width: 3, color: vibe.primaryText),
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: vibe.shadowColor,
                blurRadius: 0,
                offset: _isPressed ? Offset.zero : vibe.shadowOffset,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 3, color: vibe.primaryText),
                  ),
                ),
                child: Hero(
                  tag: '${widget.heroPrefix ?? 'watching'}_${widget.entry.id}',
                  child: SizedBox(
                    width: 100,
                    child: Builder(
                      builder: (context) {
                        final image = ExpressiveImage(
                          imageUrl: widget.entry.anime.coverImage,
                          fit: BoxFit.cover,
                          width: 100,
                          height: double.infinity,
                          skeletonColor: widget.entry.anime.parsedColor,
                        );

                        if (vibe.imageFilter == null) return image;

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ColorFiltered(
                              colorFilter: vibe.imageFilter!,
                              child: image,
                            ),
                            GrainOverlay(opacity: vibe.grainOpacity),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Info & Controls Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.entry.anime.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.teko(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 0.9,
                          color: vibe.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  color: vibe.primaryText,
                                  child: Text(
                                    'EPISODE ${widget.progress}',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: vibe.primaryText,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: progressFraction,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                    color: vibe.shadowColor,
                                    minHeight: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasNext) ...[
                            const SizedBox(width: 8),
                            // Minus Button
                            if (widget.progress > 0 &&
                                widget.onDecrement != null)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    widget.onDecrement?.call();
                                  },
                                  borderRadius: BorderRadius.zero,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor,
                                      border: Border.all(
                                        color: vibe.primaryText,
                                        width: 2,
                                      ),
                                      shape: BoxShape.rectangle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: vibe.primaryText,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.remove_sharp,
                                      color: vibe.primaryText,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            // Plus Button
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ConfettiWidget(
                                  confettiController: _confettiController,
                                  blastDirectionality:
                                      BlastDirectionality.explosive,
                                  shouldLoop: false,
                                  gravity: 0.2,
                                  numberOfParticles: 10,
                                  maxBlastForce: 5,
                                  minBlastForce: 2,
                                  colors: const [
                                    Colors.red,
                                    Colors.blue,
                                    Colors.green,
                                    Colors.yellow,
                                    Colors.purple,
                                    Colors.orange,
                                  ],
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      widget.onIncrement();
                                      _confettiController.play();
                                    },
                                    borderRadius: BorderRadius.zero,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: vibe.shadowColor,
                                        shape: BoxShape.rectangle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: vibe.primaryText,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.add_sharp,
                                        color: ExpressiveTheme.getContrastText(
                                          vibe.shadowColor,
                                        ),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
