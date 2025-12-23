import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/anilist_service.dart';
import '../models/watching_entry.dart';
import 'anime_details_page.dart';
import '../widgets/watching_card.dart';
import '../widgets/expressive_image.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/outlined_star.dart';
import '../utils/color_parser.dart';

class LibraryPage extends StatefulWidget {
  final String? initialTabName;
  const LibraryPage({super.key, this.initialTabName});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  Map<String, List<WatchingEntry>>? _libraryData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Defer the snackbar until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fetching library...'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.black,
          ),
        );
      }
    });
    _fetchLibrary();
  }

  Future<void> _fetchLibrary() async {
    try {
      final data = await AniListService().getLibraryLists();
      if (mounted) {
        setState(() {
          _libraryData = data;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _handleIncrement(WatchingEntry entry, String listName) async {
    final currentProgress = entry.progress;
    final totalEpisodes = entry.anime.episodes;

    if (totalEpisodes != null && currentProgress >= totalEpisodes) {
      return;
    }

    final newProgress = currentProgress + 1;

    // Optimistic Update
    setState(() {
      final list = _libraryData![listName]!;
      final index = list.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        list[index] = WatchingEntry(
          id: entry.id,
          anime: entry.anime,
          userScore: entry.userScore,
          progress: newProgress,
        );
      }
    });

    try {
      await AniListService().updateEpisodeProgress(
        entry.anime.id,
        newProgress,
        totalEpisodes,
      );
    } catch (e) {
      // Revert on failure
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
        setState(() {
          final list = _libraryData![listName]!;
          final index = list.indexWhere((e) => e.id == entry.id);
          if (index != -1) {
            list[index] = entry; // Revert to original
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Container(
            width: 200,
            height: 32,
            color: Colors.grey[300],
          ).animate(onPlay: (c) => c.repeat()).shimmer(),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.65,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => const AnimeCardSkeleton()
              .animate(delay: (index * 100).ms)
              .fadeIn(),
        ),
      );
    }

    if (_errorMessage != null ||
        _libraryData == null ||
        _libraryData!.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: _EmptyLibraryState(),
      );
    }

    final library = _libraryData!;
    final listNames = library.keys.toList()
      ..sort((a, b) {
        const order = [
          'Watching',
          'Planning',
          'Completed',
          'Dropped',
          'Paused',
          'Rewatching',
        ];
        int indexA = order.indexOf(a);
        int indexB = order.indexOf(b);
        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;
        return indexA.compareTo(indexB);
      });

    int initialIndex = 0;
    if (widget.initialTabName != null) {
      initialIndex = listNames.indexWhere(
        (name) => name.toLowerCase() == widget.initialTabName!.toLowerCase(),
      );
      if (initialIndex == -1) initialIndex = 0;
    }

    return DefaultTabController(
      length: listNames.length,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'YOUR LIBRARY',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 32,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.black,
            indicatorWeight: 4,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.teko(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            tabs: listNames
                .map((name) => Tab(text: name.toUpperCase()))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: listNames.map((name) {
            final entries = library[name]!;
            return _buildListContent(context, name, entries);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context,
    String listName,
    List<WatchingEntry> entries,
  ) {
    if (entries.isEmpty) {
      return const _EmptyLibraryState();
    }

    if (listName == 'Watching' || listName == 'Current') {
      return ListView.builder(
        key: PageStorageKey<String>('library_list_$listName'),
        padding: const EdgeInsets.all(24),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                const AnimeCardSkeleton(
                  isHorizontal: true,
                  width: double.infinity,
                  height: 140,
                ),
                WatchingCard(
                      entry: entry,
                      progress: entry.progress,
                      heroPrefix: 'library',
                      onIncrement: () => _handleIncrement(entry, listName),
                      width: double.infinity,
                      height: 140,
                    )
                    .animate(delay: (index < 6 ? index * 100 : 0).ms)
                    .fadeIn()
                    .slideX(begin: 0.1, end: 0),
              ],
            ),
          );
        },
      );
    }
    return GridView.builder(
      key: PageStorageKey<String>('library_grid_$listName'),
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.65,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Stack(
          children: [
            const AnimeCardSkeleton(),
            _buildLibraryCard(context, entry).animate().fadeIn().scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLibraryCard(BuildContext context, WatchingEntry entry) {
    final anime = entry.anime;
    final shadowColor = ColorParser.parseAnimeColor(anime.color);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnimeDetailsPage(anime: anime),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 3, color: Colors.black),
          boxShadow: [
            BoxShadow(color: shadowColor, offset: const Offset(6, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExpressiveImage(
                    imageUrl: anime.coverImage,
                    fit: BoxFit.cover,
                    skeletonColor: anime.parsedColor,
                  ),
                  // Progress Badge if watching
                  if (entry.progress > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          'EP ${entry.progress}',
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Score Badge
                  if (entry.userScore > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const OutlinedStar(size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.userScore}',
                              style: GoogleFonts.robotoMono(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(width: 3, color: Colors.black)),
              ),
              child: Text(
                anime.title.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.teko(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 0.9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibraryState extends StatelessWidget {
  const _EmptyLibraryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 4),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(8, 8)),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.auto_stories_outlined, size: 64, color: Colors.black)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2.seconds, color: Colors.grey[200]),
                const SizedBox(height: 16),
                Text(
                  'LIBRARY IS EMPTY',
                  style: GoogleFonts.teko(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to see your library!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.teko(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }
}
