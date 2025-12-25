import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../services/anime_store.dart';
import '../models/watching_entry.dart';
import 'anime_details_page.dart';
import '../widgets/watching_card.dart';

import '../widgets/expressive_vibe_image.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/outlined_star.dart';
import '../widgets/octopus_mascot.dart';
import '../theme/expressive_theme.dart';

import '../widgets/pressable_card.dart';

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
    // No need to fetch here - the AnimeStore is shared and already loaded by the home page
    // If the user navigates directly to this page (unlikely in current app flow),
    // the store will handle showing loading/empty states appropriately
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
        final vibeScore = context.read<AnimeStore>().vibeScore;
        final primaryText = ExpressiveTheme.getPrimaryText(vibeScore);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Updated!'),
            duration: const Duration(milliseconds: 300),
            backgroundColor: primaryText,
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
    final vibeScore = store.vibeScore;
    final primaryText = ExpressiveTheme.getPrimaryText(vibeScore);
    final vibeDuration = ExpressiveTheme.vibeDuration(vibeScore);

    if (store.isLoading && store.listNames.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              .fadeIn(duration: vibeDuration),
        ),
      );
    }

    if (store.error != null && store.listNames.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text(store.error!, style: TextStyle(color: primaryText)),
        ),
      );
    }

    if (store.listNames.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _EmptyLibraryState(vibeScore: vibeScore),
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
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: Text(
                'YOUR LIBRARY',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 32,
                  color: primaryText,
                ),
              ),
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: primaryText,
                indicatorWeight: 4,
                dividerHeight: 0,
                labelColor: primaryText,
                unselectedLabelColor: primaryText.withValues(alpha: 0.5),
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
                  icon: Icon(Icons.sort, color: primaryText, size: 28),
                  surfaceTintColor: Colors.transparent,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: primaryText, width: 3),
                  ),
                  onSelected: (mode) {
                    setState(() {
                      _sortMode = mode;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: LibrarySortMode.name,
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, color: primaryText),
                          const SizedBox(width: 12),
                          Text(
                            'NAME',
                            style: GoogleFonts.teko(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: LibrarySortMode.lastUpdated,
                      child: Row(
                        children: [
                          Icon(Icons.history, color: primaryText),
                          const SizedBox(width: 12),
                          Text(
                            'LAST UPDATED',
                            style: GoogleFonts.teko(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
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
                  vibeScore: vibeScore,
                );
              }).toList(),
            ),
          ),
          // Upside-down peeking octopus positioned behind the AppBar
          Positioned(
            top: -30, // Adjust vertical position
            right:
                80, // Adjust horizontal position (to the left of sort button)
            child: const OctopusMascot(
              size: 100,
              rotation: 180, // Upside-down
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryTabContent extends StatefulWidget {
  final String listName;
  final Future<void> Function(WatchingEntry, String, int) onUpdate;
  final LibrarySortMode sortMode;
  final double vibeScore;

  const _LibraryTabContent({
    required this.listName,
    required this.onUpdate,
    required this.sortMode,
    required this.vibeScore,
  });

  @override
  State<_LibraryTabContent> createState() => _LibraryTabContentState();
}

class _LibraryTabContentState extends State<_LibraryTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Cache sorted entries to avoid re-sorting on every build
  List<WatchingEntry>? _cachedEntries;
  LibrarySortMode? _lastSortMode;
  int? _lastEntriesHash;

  List<WatchingEntry> _getSortedEntries(
    List<WatchingEntry> rawEntries,
    LibrarySortMode sortMode,
  ) {
    // Calculate a simple hash of the entries to detect changes
    final entriesHash = rawEntries.length * 1000 + rawEntries.hashCode;

    // Only re-sort if sort mode changed or entries changed
    if (_cachedEntries != null &&
        _lastSortMode == sortMode &&
        _lastEntriesHash == entriesHash) {
      return _cachedEntries!;
    }

    // Create a copy and sort
    final entries = List<WatchingEntry>.from(rawEntries);
    if (sortMode == LibrarySortMode.name) {
      entries.sort((a, b) => a.anime.title.compareTo(b.anime.title));
    } else if (sortMode == LibrarySortMode.lastUpdated) {
      entries.sort((a, b) {
        final timeA = a.updatedAt ?? 0;
        final timeB = b.updatedAt ?? 0;
        return timeB.compareTo(timeA); // Newest first
      });
    }

    // Cache the result
    _cachedEntries = entries;
    _lastSortMode = sortMode;
    _lastEntriesHash = entriesHash;

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final store = context.watch<AnimeStore>();
    final rawEntries = store.getListEntries(widget.listName);

    // Use cached sorted entries
    final entries = _getSortedEntries(rawEntries, widget.sortMode);

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
              .fadeIn(duration: ExpressiveTheme.vibeDuration(widget.vibeScore)),
        );
      }
      return _EmptyLibraryState(vibeScore: widget.vibeScore);
    }

    final vibeDuration = ExpressiveTheme.vibeDuration(widget.vibeScore);
    final vibeCurve = ExpressiveTheme.vibeCurve(widget.vibeScore);

    if (widget.listName == 'Watching' || widget.listName == 'Current') {
      return ListView.builder(
        key: PageStorageKey<String>('library_list_${widget.listName}'),
        padding: const EdgeInsets.all(24),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _AnimatedWatchingCard(
              entry: entry,
              listName: widget.listName,
              vibeScore: widget.vibeScore,
              vibeDuration: vibeDuration,
              vibeCurve: vibeCurve,
              onUpdate: widget.onUpdate,
            ),
          );
        },
      );
    }

    return GridView.builder(
      key: PageStorageKey<String>('library_grid_${widget.listName}'),
      cacheExtent: 1000,
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
        return _AnimatedLibraryCard(
          entry: entry,
          vibeScore: widget.vibeScore,
          vibeDuration: vibeDuration,
          vibeCurve: vibeCurve,
        );
      },
    );
  }
}

// Wrapper widget for WatchingCard that animates when scrolling into view
class _AnimatedWatchingCard extends StatefulWidget {
  final WatchingEntry entry;
  final String listName;
  final double vibeScore;
  final Duration vibeDuration;
  final Curve vibeCurve;
  final Future<void> Function(WatchingEntry, String, int) onUpdate;

  const _AnimatedWatchingCard({
    required this.entry,
    required this.listName,
    required this.vibeScore,
    required this.vibeDuration,
    required this.vibeCurve,
    required this.onUpdate,
  });

  @override
  State<_AnimatedWatchingCard> createState() => _AnimatedWatchingCardState();
}

class _AnimatedWatchingCardState extends State<_AnimatedWatchingCard> {
  double _animationTarget = 0;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: VisibilityDetector(
        key: Key('watching_card_visibility_${widget.entry.id}'),
        onVisibilityChanged: (info) {
          // Trigger animation as soon as card starts becoming visible
          // Only update if we haven't animated yet (target is still 0)
          if (_animationTarget == 0 && info.visibleFraction > 0.05) {
            // Use setState but only once per card
            setState(() {
              _animationTarget = 1;
            });
          }
        },
        child:
            WatchingCard(
                  entry: widget.entry,
                  progress: widget.entry.progress,
                  heroPrefix: 'library',
                  vibeScore: widget.vibeScore,
                  onIncrement: () =>
                      widget.onUpdate(widget.entry, widget.listName, 1),
                  width: double.infinity,
                  height: 140,
                )
                .animate(target: _animationTarget)
                // .fadeIn(begin: 0.5, duration: widget.vibeDuration * 0.8)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: widget.vibeDuration * 0.8,
                  curve: widget.vibeCurve,
                ),
      ),
    );
  }
}

// Wrapper widget that animates when scrolling into view
class _AnimatedLibraryCard extends StatefulWidget {
  final WatchingEntry entry;
  final double vibeScore;
  final Duration vibeDuration;
  final Curve vibeCurve;

  const _AnimatedLibraryCard({
    required this.entry,
    required this.vibeScore,
    required this.vibeDuration,
    required this.vibeCurve,
  });

  @override
  State<_AnimatedLibraryCard> createState() => _AnimatedLibraryCardState();
}

class _AnimatedLibraryCardState extends State<_AnimatedLibraryCard> {
  double _animationTarget = 0;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: VisibilityDetector(
        key: Key('library_card_visibility_${widget.entry.id}'),
        onVisibilityChanged: (info) {
          // Trigger animation as soon as card starts becoming visible
          // Only update if we haven't animated yet (target is still 0)
          if (_animationTarget == 0 && info.visibleFraction > 0.05) {
            // Use setState but only once per card
            setState(() {
              _animationTarget = 1;
            });
          }
        },
        child: _LibraryCard(entry: widget.entry, vibeScore: widget.vibeScore)
            .animate(target: _animationTarget)
            .fadeIn(begin: 0.75, duration: widget.vibeDuration * 0.8)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: widget.vibeDuration * 0.8,
              curve: widget.vibeCurve,
            ),
      ),
    );
  }
}

class _LibraryCard extends StatefulWidget {
  final WatchingEntry entry;
  final double vibeScore;

  const _LibraryCard({required this.entry, required this.vibeScore});

  @override
  State<_LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<_LibraryCard> {
  // Cache expensive theme calculations
  late final Color _shadowColor;
  late final Offset _shadowOffset;
  late final Color _primaryText;

  @override
  void initState() {
    super.initState();
    final anime = widget.entry.anime;
    _shadowColor = ExpressiveTheme.getShadowColor(
      widget.vibeScore,
      anime.parsedColor,
    );
    _shadowOffset = ExpressiveTheme.getShadowOffset(widget.vibeScore);
    _primaryText = ExpressiveTheme.getPrimaryText(widget.vibeScore);
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.entry.anime;
    final shadowColor = _shadowColor;
    final shadowOffset = _shadowOffset;
    final primaryText = _primaryText;

    return PressableCard(
      shadowOffset: shadowOffset,
      onTap: () {
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnimeDetailsPage(anime: anime),
          ),
        );
      },
      builder: (context, isPressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutQuad,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(width: 3, color: primaryText),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: isPressed ? Offset.zero : shadowOffset,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExpressiveVibeImage(
                    imageUrl: anime.coverImage,
                    fit: BoxFit.cover,
                    skeletonColor: anime.parsedColor,
                    vibeScore: widget.vibeScore,
                  ),
                  if (widget.entry.progress > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryText,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'EP ${widget.entry.progress}',
                          style: GoogleFonts.robotoMono(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (widget.entry.userScore > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: Border.all(color: primaryText, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: primaryText,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedStar(size: 12, color: primaryText),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.entry.userScore}',
                              style: GoogleFonts.robotoMono(
                                color: primaryText,
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
              decoration: BoxDecoration(
                border: Border(top: BorderSide(width: 3, color: primaryText)),
              ),
              child: Text(
                anime.title.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.teko(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 0.9,
                  color: primaryText,
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
  final double vibeScore;
  const _EmptyLibraryState({required this.vibeScore});

  @override
  Widget build(BuildContext context) {
    final primaryText = ExpressiveTheme.getPrimaryText(vibeScore);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: primaryText, width: 4),
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(color: primaryText, offset: const Offset(8, 8)),
              ],
            ),
            child: Column(
              children: [
                const OctopusMascot(size: 80),
                const SizedBox(height: 16),
                Text(
                  'LIBRARY IS EMPTY',
                  style: GoogleFonts.teko(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to see your library!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.teko(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: primaryText.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ).animate().scale(
            delay: 200.ms,
            curve: ExpressiveTheme.vibeCurve(vibeScore),
            duration: ExpressiveTheme.vibeDuration(vibeScore),
          ),
        ],
      ),
    );
  }
}
