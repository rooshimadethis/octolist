import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/anime.dart';
import '../models/user_profile.dart';
import '../services/anilist_service.dart';
import '../services/mock_data_service.dart';
import 'library_page.dart';
import '../widgets/watching_card.dart';
import '../widgets/anime_card_skeleton.dart';
import '../widgets/manga_card.dart';
import '../widgets/section_title.dart';
import '../widgets/user_profile_dialog.dart';
import '../widgets/expressive_image.dart';
import '../theme/expressive_theme.dart';
import '../utils/greeting_helper.dart';

class ExpressiveApp extends StatelessWidget {
  const ExpressiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ExpressiveTheme.themeData,
      home: const ExpressiveHomePage(),
    );
  }
}

class ExpressiveHomePage extends StatefulWidget {
  const ExpressiveHomePage({super.key});

  @override
  State<ExpressiveHomePage> createState() => _ExpressiveHomePageState();
}

class _ExpressiveHomePageState extends State<ExpressiveHomePage> {
  int _selectedIndex = 0;
  final Map<int, int> _progressOverrides = {};
  String _searchQuery = 'naruto';
  final TextEditingController _searchController = TextEditingController(
    text: 'naruto',
  );
  String? _libraryInitialTab;
  Key _libraryKey = const PageStorageKey('library_page');

  late AniListService _aniListService;
  late Future<UserProfile?> _profileFuture;
  late Future<List<WatchingEntry>> _watchingFuture;
  late Future<List<Anime>> _trendingFuture;
  late Future<List<Anime>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _aniListService = AniListService();
    _profileFuture = _aniListService.getUserProfile();
    _watchingFuture = _aniListService.getWatchingList();
    _trendingFuture = _aniListService.getTrendingAnime();
    _searchFuture = _aniListService.searchAnime(_searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _incrementProgress(int entryId, int currentProgress) {
    // TODO: Stub - In a real app, this would call an API to update progress
    setState(() {
      _progressOverrides[entryId] = currentProgress + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

                        final greeting = GreetingHelper.getGreeting();

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  Text(
                                    '$greeting, $name',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: Colors.black,
                                          fontSize: 32,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    color: Colors.black,
                                    child: Text(
                                      'Let\'s find some anime.',
                                      style: GoogleFonts.teko(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.0,
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
                                  if (user != null) {
                                    UserProfileDialog.show(context, user);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // Circular avatar
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 0,
                                        offset: Offset(4, 4),
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
                  // Watching Section
                  SectionTitle(
                    title: 'Continue Watching',
                    onPressed: () {
                      setState(() {
                        _libraryInitialTab = 'Watching';
                        _selectedIndex = 2;
                        _libraryKey = UniqueKey();
                      });
                    },
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180, // Reduced height for better aspect ratio
                    child: FutureBuilder<List<WatchingEntry>>(
                      future: _watchingFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) =>
                                const AnimeCardSkeleton(
                                  isHorizontal: true,
                                ).animate(delay: (index * 100).ms).fadeIn(),
                          );
                        }
                        final entries = snapshot.data ?? [];
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          scrollDirection: Axis.horizontal,
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final progress =
                                _progressOverrides[entry.id] ?? entry.progress;
                            return Stack(
                              key: ValueKey('watching_${entry.id}'),
                              children: [
                                const AnimeCardSkeleton(isHorizontal: true),
                                WatchingCard(
                                      entry: entry,
                                      progress: progress,
                                      heroPrefix: 'home',
                                      onIncrement: () => _incrementProgress(
                                        entry.id,
                                        progress,
                                      ),
                                    )
                                    .animate(
                                      delay: (index < 6 ? index * 100 : 0).ms,
                                    )
                                    .fadeIn()
                                    .slideX(begin: 0.1, end: 0),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Trending Section
                  // Trending Section
                  SectionTitle(
                    title: 'Trending Now',
                    // Button removed as per request
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
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
                                    .fadeIn(),
                          );
                        }
                        final animeList = snapshot.data ?? [];
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          scrollDirection: Axis.horizontal,
                          itemCount: animeList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            return Stack(
                              key: ValueKey('trending_${animeList[index].id}'),
                              children: [
                                const AnimeCardSkeleton(),
                                MangaCard(anime: animeList[index])
                                    .animate(
                                      delay: (index < 6 ? index * 100 : 0).ms,
                                    )
                                    .fadeIn()
                                    .scale(
                                      begin: const Offset(0.9, 0.9),
                                      end: const Offset(1.0, 1.0),
                                    ),
                              ],
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.isEmpty ? 'naruto' : value;
                        _searchFuture = MockDataService().searchAnime(
                          _searchQuery,
                        );
                      });
                    },
                    style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'FIND MANGA...',
                      hintStyle: GoogleFonts.teko(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Colors.black,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 4,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
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
                                    .fadeIn(),
                          );
                        }
                        final animeList = snapshot.data ?? [];
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
                            return Stack(
                              key: ValueKey('search_${animeList[index].id}'),
                              children: [
                                const AnimeCardSkeleton(),
                                MangaCard(anime: animeList[index])
                                    .animate(
                                      delay: (index < 10 ? index * 100 : 0).ms,
                                    )
                                    .fadeIn()
                                    .scale(
                                      begin: const Offset(0.9, 0.9),
                                      end: const Offset(1, 1),
                                    ),
                              ],
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                color: Colors.black,
              ),
            ),
            iconTheme: WidgetStateProperty.all(
              IconThemeData(color: Colors.black),
            ),
          ),
          child: NavigationBar(
            // height: 50,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() {
              _selectedIndex = index;
              if (index != 2) {
                _libraryInitialTab = null;
              }
            }),
            elevation: 0,
            backgroundColor: Colors.white,
            indicatorColor:
                Colors.grey[300], // Softer indicator for manga style
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
