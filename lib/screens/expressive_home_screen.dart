import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/anime.dart';
import '../models/user_profile.dart';
import '../models/watching_entry.dart';
import '../services/anime_service_interface.dart';
import '../services/auth_service.dart';
import '../services/anime_store.dart';
import 'library_page.dart';
import '../widgets/watching_card.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/manga_card.dart';
import '../widgets/section_title.dart';
import '../widgets/user_profile_dialog.dart';
import '../widgets/expressive_image.dart';
import '../widgets/octopus_mascot.dart';
import '../widgets/typewriter_text.dart';
import '../theme/expressive_theme.dart';
import '../utils/greeting_helper.dart';
import '../utils/vibe_text_helper.dart';
import '../utils/snackbar_helper.dart';

class ExpressiveApp extends StatelessWidget {
  const ExpressiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Selector to only rebuild when vibeScore changes
    return Selector<AnimeStore, double>(
      selector: (_, store) => store.vibeScore,
      builder: (context, vibeScore, _) {
        // Build MaterialApp directly without TweenAnimationBuilder
        // This prevents full app rebuilds and eliminates startup stuttering
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ExpressiveTheme.themeData(vibeScore: vibeScore),
          home: ExpressiveHomePage(vibeScore: vibeScore),
          builder: (context, child) {
            return child!;
          },
        );
      },
    );
  }
}

class ExpressiveHomePage extends StatefulWidget {
  final double vibeScore;
  const ExpressiveHomePage({super.key, this.vibeScore = 0.0});

  @override
  State<ExpressiveHomePage> createState() => _ExpressiveHomePageState();
}

class _ExpressiveHomePageState extends State<ExpressiveHomePage> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _libraryInitialTab;
  final Key _libraryKey = const PageStorageKey('library_page');

  late IAnimeService _animeService;
  late Future<UserProfile?> _profileFuture;
  late Future<List<Anime>> _trendingFuture;
  late Future<List<Anime>> _searchFuture;

  // Cache VibeColors to avoid recalculating on every build
  VibeColors? _cachedVibeColors;
  double? _cachedVibeScore;

  VibeColors get _vibe {
    if (_cachedVibeColors == null || _cachedVibeScore != widget.vibeScore) {
      _cachedVibeColors = VibeColors.fromScore(widget.vibeScore);
      _cachedVibeScore = widget.vibeScore;
    }
    return _cachedVibeColors!;
  }

  @override
  void initState() {
    super.initState();
    _animeService = context.read<AnimeStore>().service;
    _loadData();

    // Listen for auth changes to refresh data
    AuthService().isLoggedIn.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthService().isLoggedIn.removeListener(_onAuthChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SnackBarHelper.showInfo(
          context,
          message: 'Refreshing home data...',
          duration: const Duration(seconds: 1),
        );
      }
    });

    // Fetch user profile once and reuse it
    _profileFuture = _animeService.getUserProfile();

    // Use the profile to fetch library without duplicate getUserProfile call
    _profileFuture.then((profile) {
      if (profile != null && mounted) {
        context.read<AnimeStore>().fetchLibraryWithUser(profile);
      }
    });

    // Fetch trending in parallel
    _trendingFuture = _animeService.getTrendingAnime();

    _searchFuture = _searchQuery.isEmpty
        ? Future.value([])
        : _animeService.searchAnime(_searchQuery);
  }

  void _onAuthChanged() {
    if (mounted) {
      if (AuthService().isLoggedIn.value) {
        SnackBarHelper.showSuccess(
          context,
          message: 'Successfully logged in to AniList!',
        );
      }
      setState(() {
        _loadData();
      });
    }
  }

  Future<void> _updateProgress(
    WatchingEntry entry,
    int currentProgress,
    int delta,
  ) async {
    try {
      await context.read<AnimeStore>().updateProgress(entry.anime.id, delta);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        SnackBarHelper.showSuccess(
          context,
          message: 'Progress updated!',
          duration: const Duration(milliseconds: 500),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          message: 'Failed to update progress: $e',
        );
      }
    }
  }

  void _performSearch() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _searchFuture = _searchQuery.isEmpty
          ? Future.value([])
          : _animeService.searchAnime(_searchQuery);
    });

    if (_searchQuery.isNotEmpty) {
      SnackBarHelper.showInfo(
        context,
        message: 'Searching for "$_searchQuery"...',
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vibe = _vibe; // Use cached VibeColors

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FutureBuilder<UserProfile?>(
                      future: _profileFuture,
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        final name = user?.name ?? 'Guest';
                        final avatarUrl = user?.avatarLarge;
                        final isGuest = user == null;

                        final greeting = GreetingHelper.getGreeting(
                          context.read<AnimeStore>().vibeLevel,
                        );

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: TypewriterText(
                                      text: '${greeting.title} $name',
                                      maxLines: 1,
                                      duration: const Duration(
                                        milliseconds: 1200,
                                      ),
                                      showCursor: true,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontSize: 28,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (isGuest)
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          // TODO: Use dependency injection for AuthService
                                          // Creating a temporary instance here just to trigger login
                                          // Ideally AuthService should be a singleton or provider
                                          await AuthService().login();
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Login failed: $e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: vibe.primaryText,
                                        foregroundColor: vibe.scaffoldBg,
                                        shape: const RoundedRectangleBorder(),
                                      ),
                                      child: Text(
                                        'LOGIN WITH ANILIST',
                                        style: GoogleFonts.teko(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else if (greeting.subtitle.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      color: vibe.primaryText,
                                      child: Text(
                                        greeting.subtitle,
                                        style: GoogleFonts.teko(
                                          color: vibe.scaffoldBg,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ), // Spacing between text and avatar
                            if (avatarUrl != null && avatarUrl.isNotEmpty)
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      if (user != null) {
                                        UserProfileDialog.show(context, user);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape:
                                            BoxShape.circle, // Circular avatar
                                        border: Border.all(
                                          color: vibe.primaryText,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                ExpressiveTheme.getShadowColor(
                                                  widget.vibeScore,
                                                ),
                                            blurRadius: 0,
                                            offset: const Offset(4, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: ExpressiveImage(
                                          imageUrl: avatarUrl,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Octopus sitting on left side of avatar
                                  Positioned(
                                    top: -25,
                                    left: -10,
                                    child: OctopusMascot(
                                      size: 50,
                                      rotation: -20,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Watching Section (Always visible - shows skeletons when empty)
                  Consumer<AnimeStore>(
                    builder: (context, store, _) {
                      final entries = store.getListEntries('Watching');

                      // Always show the section (optimistic UI)
                      // Skeletons appear when entries are empty
                      return Column(
                        children: [
                          SectionTitle(
                                title: VibeTextHelper.getContinueWatchingHeader(
                                  store.vibeLevel,
                                ),
                                vibeScore: widget.vibeScore,
                                onPressed: () {
                                  setState(() {
                                    _libraryInitialTab = 'Watching';
                                    _selectedIndex = 2;
                                  });
                                },
                              )
                              .animate()
                              .fadeIn(
                                delay: 100.ms,
                                duration: vibe.animationDuration,
                              )
                              .slideX(
                                begin: -0.2,
                                end: 0,
                                curve: vibe.animationCurve,
                                duration: vibe.animationDuration,
                              ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: ListView.separated(
                              cacheExtent: entries.isEmpty ? null : 2000,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: entries.isEmpty ? 3 : entries.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                if (entries.isEmpty) {
                                  // Only animate first 3 skeleton cards
                                  final skeleton = const AnimeCardSkeleton(
                                    isHorizontal: true,
                                  );

                                  if (index < 3) {
                                    return skeleton
                                        .animate(delay: (index * 100).ms)
                                        .fadeIn(
                                          duration: vibe.animationDuration,
                                        );
                                  }
                                  return skeleton;
                                }

                                // Render Real Card
                                final entry = entries[index];
                                final card = WatchingCard(
                                  entry: entry,
                                  progress: entry.progress,
                                  heroPrefix: 'home',
                                  vibeScore: widget.vibeScore,
                                  onIncrement: () =>
                                      _updateProgress(entry, entry.progress, 1),
                                );

                                return _AnimatedVisibilityCard(
                                  id: 'watching_${entry.id}',
                                  vibeScore: widget.vibeScore,
                                  child: card,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Trending Section
                  // Trending Section
                  SectionTitle(
                        title: VibeTextHelper.getTrendingNowHeader(
                          context.read<AnimeStore>().vibeLevel,
                        ),
                        vibeScore: widget.vibeScore,
                        // Button removed as per request
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: vibe.animationDuration)
                      .slideX(
                        begin: -0.2,
                        end: 0,
                        curve: vibe.animationCurve,
                        duration: vibe.animationDuration,
                      ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 310,
                    child: FutureBuilder<List<Anime>>(
                      future: _trendingFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            itemCount: 4,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final skeleton = const AnimeCardSkeleton();
                              if (index < 3) {
                                return skeleton
                                    .animate(delay: (index * 100).ms)
                                    .fadeIn(duration: vibe.animationDuration);
                              }
                              return skeleton;
                            },
                          );
                        }
                        final animeList = snapshot.data ?? [];
                        return ListView.separated(
                          cacheExtent: 2000,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          scrollDirection: Axis.horizontal,
                          itemCount: animeList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final card = Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: MangaCard(
                                anime: animeList[index],
                                vibeScore: widget.vibeScore,
                              ),
                            );

                            return _AnimatedVisibilityCard(
                              id: 'trending_${animeList[index].id}',
                              vibeScore: widget.vibeScore,
                              child: card,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Page
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEARCH',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: vibe.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
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
                      color: vibe.primaryText,
                    ),
                    decoration: InputDecoration(
                      hintText: VibeTextHelper.getSearchHint(
                        context.read<AnimeStore>().vibeLevel,
                      ),
                      hintStyle: GoogleFonts.teko(
                        fontSize: 20,
                        color: vibe.primaryText.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: vibe.primaryText,
                      ),
                      filled: true,
                      fillColor: vibe.scaffoldBg,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: vibe.primaryText,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: vibe.primaryText,
                          width: 4,
                        ),
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
                      backgroundColor: vibe.primaryText,
                      foregroundColor: vibe.scaffoldBg,
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.7,
                                ),
                            itemCount: 6,
                            itemBuilder: (context, index) =>
                                const AnimeCardSkeleton()
                                    .animate(
                                      delay: (index < 3 ? index * 100 : 0).ms,
                                    )
                                    .fadeIn(duration: vibe.animationDuration),
                          );
                        }

                        // New Error Handling UI for Search
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
                                color: vibe.primaryText.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          cacheExtent: 1000,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: animeList.length,
                          itemBuilder: (context, index) {
                            return _AnimatedVisibilityCard(
                              id: 'search_${animeList[index].id}',
                              vibeScore: widget.vibeScore,
                              child: MangaCard(
                                anime: animeList[index],
                                vibeScore: widget.vibeScore,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          LibraryPage(key: _libraryKey, initialTabName: _libraryInitialTab),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: vibe.scaffoldBg,
          boxShadow: [
            BoxShadow(
              color: vibe.primaryText.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
              GoogleFonts.teko(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: vibe.primaryText,
              ),
            ),
            iconTheme: WidgetStateProperty.all(
              IconThemeData(color: vibe.primaryText),
            ),
          ),
          child: NavigationBar(
            // height: 50,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedIndex = index;
                if (index != 2) {
                  _libraryInitialTab = null;
                }
              });
            },
            elevation: 0,
            backgroundColor: vibe.scaffoldBg,
            indicatorColor: vibe.primaryText.withValues(alpha: 0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_filled),
                label: 'HOME',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'EXPLORE',
              ),
              NavigationDestination(
                icon: Icon(Icons.video_library_outlined),
                selectedIcon: Icon(Icons.video_library),
                label: 'LIBRARY',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedVisibilityCard extends StatefulWidget {
  final Widget child;
  final String id;
  final double vibeScore;

  const _AnimatedVisibilityCard({
    required this.child,
    required this.id,
    required this.vibeScore,
  });

  @override
  State<_AnimatedVisibilityCard> createState() =>
      _AnimatedVisibilityCardState();
}

class _AnimatedVisibilityCardState extends State<_AnimatedVisibilityCard> {
  double _animationTarget = 0;

  @override
  Widget build(BuildContext context) {
    // Get animation params from theme
    final duration = ExpressiveTheme.vibeDuration(widget.vibeScore) * 0.8;
    final curve = ExpressiveTheme.vibeCurve(widget.vibeScore);

    return RepaintBoundary(
      child: VisibilityDetector(
        key: Key('home_card_visibility_${widget.id}'),
        onVisibilityChanged: (info) {
          if (_animationTarget == 0 && info.visibleFraction > 0.05) {
            setState(() {
              _animationTarget = 1;
            });
          }
        },
        child: widget.child
            .animate(target: _animationTarget)
            .fadeIn(begin: 0.75, duration: duration)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: duration,
              curve: curve,
            ),
      ),
    );
  }
}
