import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/watching_entry.dart';
import '../screens/anime_details_page.dart';
import 'expressive_image.dart';

class WatchingCard extends StatefulWidget {
  final WatchingEntry entry;
  final int progress;
  final VoidCallback onIncrement;
  final double? width;
  final double? height;
  final String? heroPrefix;

  const WatchingCard({
    super.key,
    required this.entry,
    required this.progress,
    required this.onIncrement,
    this.width,
    this.height,
    this.heroPrefix,
  });

  @override
  State<WatchingCard> createState() => _WatchingCardState();
}

class _WatchingCardState extends State<WatchingCard> {
  late ConfettiController _confettiController;

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

    Color shadowColor = Colors.black;
    if (widget.entry.anime.color != null) {
      try {
        shadowColor = Color(
          int.parse(widget.entry.anime.color!.replaceAll('#', '0xFF')),
        );
      } catch (_) {}
    }

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnimeDetailsPage(anime: widget.entry.anime),
            ),
          );
        },
        child: Container(
          width: widget.width ?? 280,
          height: widget.height,
          margin: const EdgeInsets.only(bottom: 12, right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 3, color: Colors.black),
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 0,
                offset: const Offset(8, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 3, color: Colors.black),
                  ),
                ),
                child: Hero(
                  tag: '${widget.heroPrefix ?? 'watching'}_${widget.entry.id}',
                  child: SizedBox(
                    width: 100,
                    child: ExpressiveImage(
                      imageUrl: widget.entry.anime.coverImage,
                      fit: BoxFit.cover,
                      width: 100,
                      height: double.infinity,
                      skeletonColor: widget.entry.anime.parsedColor,
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
                                  color: Colors.black,
                                  child: Text(
                                    'EPISODE ${widget.progress}',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: progressFraction,
                                    backgroundColor: Colors.white,
                                    color: shadowColor,
                                    minHeight: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasNext) ...[
                            const SizedBox(width: 12),
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
                                      widget.onIncrement();
                                      _confettiController.play();
                                    },
                                    borderRadius: BorderRadius.zero,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.rectangle,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.add_sharp,
                                        color: Colors.white,
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
