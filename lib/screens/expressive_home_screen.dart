import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../theme/expressive_theme.dart';
import '../utils/greeting_helper.dart';
import '../utils/vibe_text_helper.dart';

class ExpressiveApp extends StatelessWidget {
  const ExpressiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AnimeStore, double>(
      selector: (_, store) => store.vibeScore,
      builder: (context, vibeScore, _) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: vibeScore),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
          builder: (context, animatedVibe, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ExpressiveTheme.themeData(vibeScore: animatedVibe),
              home: ExpressiveHomePage(vibeScore: animatedVibe),
              builder: (context, child) {
                return child!;
              },
            );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Refreshing home data...'),
            duration: const Duration(seconds: 1),
            backgroundColor: ExpressiveTheme.getPrimaryText(widget.vibeScore),
          ),
        );
      }
    });
    _profileFuture = _animeService.getUserProfile();
    // Use the store for watching data
    context.read<AnimeStore>().fetchLibrary();
    _trendingFuture = _animeService.getTrendingAnime();
    _searchFuture = _searchQuery.isEmpty
        ? Future.value([])
        : _animeService.searchAnime(_searchQuery);
  }

  void _onAuthChanged() {
    if (mounted) {
      if (AuthService().isLoggedIn.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged in to AniList!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
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
        final currentVibe = VibeColors.fromScore(
          context.read<AnimeStore>().vibeScore,
        );
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Progress updated!'),
            backgroundColor: currentVibe.primaryText,
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update progress: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _performSearch() {
    setState(() {
      _searchFuture = _searchQuery.isEmpty
          ? Future.value([])
          : _animeService.searchAnime(_searchQuery);
    });

    if (_searchQuery.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching for "$_searchQuery"...'),
          duration: const Duration(milliseconds: 500),
          backgroundColor: ExpressiveTheme.getPrimaryText(widget.vibeScore),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vibe = VibeColors.fromScore(widget.vibeScore);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
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
                          vibeScore: widget.vibeScore,
                        );

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${greeting.title} $name',
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontSize: 32,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      color: vibe.primaryText,
                                      child: Text(
                                        greeting.subtitle,
                                        style: GoogleFonts.teko(
                                          color: vibe.scaffoldBg,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2.0,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ), // Spacing between text and avatar
                            if (avatarUrl != null && avatarUrl.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (user != null) {
                                    UserProfileDialog.show(context, user);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // Circular avatar
                                    border: Border.all(
                                      color: vibe.primaryText,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ExpressiveTheme.getShadowColor(
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
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Watching Section
                  Consumer<AnimeStore>(
                    builder: (context, store, _) {
                      final entries = store.getListEntries('Watching');
                      final isInitialLoading =
                          store.isLoading && entries.isEmpty;

                      // If not loading and no entries, show nothing
                      if (!isInitialLoading && entries.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      // Show Header + List (either Skeletons or Real Cards)
                      return Column(
                        children: [
                          SectionTitle(
                                title: VibeTextHelper.getContinueWatchingHeader(
                                  vibeScore: widget.vibeScore,
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
                              cacheExtent: isInitialLoading ? null : 2000,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: isInitialLoading ? 3 : entries.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                if (isInitialLoading) {
                                  return const AnimeCardSkeleton(
                                        isHorizontal: true,
                                      )
                                      .animate(delay: (index * 100).ms)
                                      .fadeIn(duration: vibe.animationDuration);
                                }

                                // Render Real Card
                                final entry = entries[index];
                                return WatchingCard(
                                      entry: entry,
                                      progress: entry.progress,
                                      heroPrefix: 'home',
                                      vibeScore: widget.vibeScore,
                                      onIncrement: () => _updateProgress(
                                        entry,
                                        entry.progress,
                                        1,
                                      ),
                                    )
                                    .animate(
                                      delay: (index < 6 ? index * 100 : 0).ms,
                                    )
                                    .fadeIn(duration: vibe.animationDuration)
                                    .slideX(
                                      begin: 0.1,
                                      end: 0,
                                      curve: vibe.animationCurve,
                                      duration: vibe.animationDuration,
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
                          vibeScore: widget.vibeScore,
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
                            itemBuilder: (context, index) =>
                                const AnimeCardSkeleton()
                                    .animate(delay: (index * 100).ms)
                                    .fadeIn(duration: vibe.animationDuration),
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
                            return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: MangaCard(
                                    anime: animeList[index],
                                    vibeScore: widget.vibeScore,
                                  ),
                                )
                                .animate(
                                  delay: (index < 6 ? index * 100 : 0).ms,
                                )
                                .fadeIn(duration: vibe.animationDuration)
                                .scale(
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1.0, 1.0),
                                  curve: vibe.animationCurve,
                                  duration: vibe.animationDuration,
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
                        vibeScore: widget.vibeScore,
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
                                    .animate(delay: (index * 100).ms)
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
                              child: Text(
                                '👀',
                                style: GoogleFonts.teko(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
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
                            return MangaCard(
                                  anime: animeList[index],
                                  vibeScore: widget.vibeScore,
                                )
                                .animate(
                                  delay: (index < 10 ? index * 100 : 0).ms,
                                )
                                .fadeIn(duration: vibe.animationDuration)
                                .scale(
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1, 1),
                                  curve: vibe.animationCurve,
                                  duration: vibe.animationDuration,
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
