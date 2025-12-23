import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/anime_store.dart';
import '../models/watching_entry.dart';
import 'anime_details_page.dart';
import '../widgets/watching_card.dart';
import '../widgets/expressive_image.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/outlined_star.dart';
import '../utils/color_parser.dart';

enum LibrarySortMode { name, lastUpdated }

class LibraryPage extends StatefulWidget {
  final String? initialTabName;
  const LibraryPage({super.key, this.initialTabName});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  LibrarySortMode _sortMode = LibrarySortMode.lastUpdated;

  @override
  void initState() {
    super.initState();
    // Fetch if needed, though usually Home or previous page might have started it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimeStore>().fetchLibrary();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleUpdate(
    WatchingEntry entry,
    String listName,
    int delta,
  ) async {
    try {
      await context.read<AnimeStore>().updateProgress(entry.anime.id, delta);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Updated!'),
            duration: Duration(milliseconds: 300),
            backgroundColor: Colors.black,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AnimeStore>();

    if (store.isLoading && store.listNames.isEmpty) {
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

    if (store.error != null && store.listNames.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text(store.error!)),
      );
    }

    if (store.listNames.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: _EmptyLibraryState(),
      );
    }

    final listNames = store.listNames;

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
          actions: [
            PopupMenuButton<LibrarySortMode>(
              icon: const Icon(Icons.sort, color: Colors.black, size: 28),
              onSelected: (mode) {
                setState(() {
                  _sortMode = mode;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: LibrarySortMode.name,
                  child: Text('NAME'),
                ),
                const PopupMenuItem(
                  value: LibrarySortMode.lastUpdated,
                  child: Text('LAST UPDATED'),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: TabBarView(
          children: listNames.map((name) {
            return _LibraryTabContent(
              listName: name,
              onUpdate: _handleUpdate,
              sortMode: _sortMode,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LibraryTabContent extends StatefulWidget {
  final String listName;
  final Future<void> Function(WatchingEntry, String, int) onUpdate;
  final LibrarySortMode sortMode;

  const _LibraryTabContent({
    required this.listName,
    required this.onUpdate,
    required this.sortMode,
  });

  @override
  State<_LibraryTabContent> createState() => _LibraryTabContentState();
}

class _LibraryTabContentState extends State<_LibraryTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final store = context.watch<AnimeStore>();
    final rawEntries = store.getListEntries(widget.listName);

    // Apply sorting
    final List<WatchingEntry> entries = List.from(rawEntries);
    if (widget.sortMode == LibrarySortMode.name) {
      entries.sort((a, b) => a.anime.title.compareTo(b.anime.title));
    } else if (widget.sortMode == LibrarySortMode.lastUpdated) {
      entries.sort((a, b) {
        final timeA = a.updatedAt ?? 0;
        final timeB = b.updatedAt ?? 0;
        return timeB.compareTo(timeA); // Newest first
      });
    }

    if (entries.isEmpty) {
      if (store.isLoading) {
        return GridView.builder(
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
        );
      }
      return const _EmptyLibraryState();
    }

    if (widget.listName == 'Watching' || widget.listName == 'Current') {
      return ListView.builder(
        key: PageStorageKey<String>('library_list_${widget.listName}'),
        cacheExtent:
            1000, // Keep more items in memory to prevent re-animation on scroll
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
                      onIncrement: () =>
                          widget.onUpdate(entry, widget.listName, 1),
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
      key: PageStorageKey<String>('library_grid_${widget.listName}'),
      cacheExtent: 1000, // Keep more items in memory
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
              end: const Offset(1.0, 1.0),
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
        HapticFeedback.lightImpact();
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
