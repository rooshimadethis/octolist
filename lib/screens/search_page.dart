import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/anime.dart';
import '../services/anime_store.dart';
import '../services/anime_service_interface.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/manga_card.dart';
import '../widgets/octopus_mascot.dart';
import '../utils/vibe_text_helper.dart';
import '../theme/expressive_theme.dart';

class SearchPage extends StatefulWidget {
  final double vibeScore;
  const SearchPage({super.key, required this.vibeScore});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Anime>> _searchFuture;
  late IAnimeService _animeService;

  @override
  void initState() {
    super.initState();
    _animeService = context.read<AnimeStore>().service;
    _searchFuture = Future.value([]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchFuture = _searchQuery.isEmpty
          ? Future.value([])
          : _animeService.searchAnime(_searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryText = ExpressiveTheme.getPrimaryText(widget.vibeScore);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SEARCH',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: primaryText,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                _searchQuery = value;
              },
              onSubmitted: (_) {
                HapticFeedback.lightImpact();
                _performSearch();
              },
              style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
              decoration: InputDecoration(
                hintText: VibeTextHelper.getSearchHint(
                  context.read<AnimeStore>().vibeLevel,
                ),
                hintStyle: GoogleFonts.teko(
                  fontSize: 20,
                  color: primaryText.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(Icons.search_rounded, color: primaryText),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: primaryText, width: 3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: primaryText, width: 4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _performSearch();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryText,
                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                minimumSize: const Size(double.infinity, 56),
                elevation: 0,
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(
                'SEARCH',
                style: GoogleFonts.teko(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Anime>>(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: 6,
                      itemBuilder: (context, index) => const AnimeCardSkeleton()
                          .animate(delay: (index < 3 ? index * 100 : 0).ms)
                          .fadeIn(duration: 400.ms),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error searching: ${snapshot.error}',
                        style: GoogleFonts.robotoMono(color: Colors.red),
                      ),
                    );
                  }

                  final animeList = snapshot.data ?? [];

                  if (animeList.isEmpty) {
                    if (_searchQuery.isEmpty) {
                      return Center(
                        child: Animate(
                          onPlay: (controller) => controller.repeat(),
                          effects: const [
                            RotateEffect(
                              duration: Duration(seconds: 3),
                              curve: Curves.linear,
                            ),
                          ],
                          child: const OctopusMascot(size: 60),
                        ),
                      );
                    }
                    return Center(
                      child: Text(
                        'NO RESULTS FOUND',
                        style: GoogleFonts.teko(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryText.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: animeList.length,
                    itemBuilder: (context, index) {
                      return MangaCard(
                        anime: animeList[index],
                        vibeScore: widget.vibeScore,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
