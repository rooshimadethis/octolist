# Expressive Anime - Manga-Inspired UI Prototype

A bold, manga/comic-inspired Flutter UI prototype for anime tracking applications. Features hard borders, dramatic shadows, and expressive typography that breaks away from standard Material Design aesthetics.

## 🎨 Design Philosophy

This prototype implements a **manga-inspired design system** characterized by:

- **Hard borders** (2-4px black outlines) instead of soft shadows
- **Zero border radius** for sharp, comic-book aesthetics
- **Offset shadows** with no blur for a hand-drawn feel
- **Bold typography** using Teko (display) and Roboto Mono (technical text)
- **High contrast** black-and-white base with accent colors
- **Expressive animations** using flutter_animate for pop-in effects

See [DESIGN.md](DESIGN.md) for detailed design principles.

---

## 📁 Project Structure

```
expressive_anime/
├── README.md                    # This file
├── DESIGN.md                    # Design system documentation
├── expressive_theme.dart        # Centralized theme configuration
├── expressive_home.dart         # Main app entry point & home screen
├── anime_details_page.dart      # Detail view for individual anime
│
├── models/
│   ├── anime.dart              # Core anime data model
│   └── user_profile.dart       # User profile & statistics model
│
├── services/
│   └── mock_data_service.dart  # Mock data service (loads from JSON assets)
│
├── screens/
│   └── library_page.dart       # Library view with tabs (Watching, Planning, etc.)
│
├── utils/
│   ├── color_parser.dart       # Hex color string parser
│   └── greeting_helper.dart    # Time-based greeting generator
│
└── widgets/
    ├── anime_card_skeleton.dart     # Skeleton loader for cards
    ├── expressive_image.dart        # Image widget with loading states
    ├── manga_card.dart              # Vertical anime card (for grids/carousels)
    ├── watching_card.dart           # Horizontal watching card with progress
    ├── metadata_chip.dart           # Genre/tag chips
    ├── outlined_star.dart           # Custom star icon for ratings
    ├── section_title.dart           # Section headers with optional buttons
    └── user_profile_dialog.dart     # User stats dialog
```

**File Dependency Hierarchy:**
```
expressive_theme.dart (no dependencies)
    ↓
models/ (no dependencies)
    ↓
widgets/ (depends on: theme, models)
    ↓
services/ (depends on: models)
    ↓
screens/ (depends on: widgets, services, models, theme)
    ↓
expressive_home.dart (depends on: everything)
```

---

## ⚡ Quick Start (5 Minutes)

### 1. Copy Files

Copy the entire `expressive_anime` folder into your project's `lib/` directory.

### 2. Install Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  google_fonts: ^6.3.3           # Teko, Roboto Mono, Bangers fonts
  flutter_animate: ^4.5.2        # Declarative animations
  cached_network_image: ^3.4.1   # Image caching
```

Run:
```bash
flutter pub get
```

### 3. Add Mock Assets (Optional for Testing)

Copy `assets/anilist_data/` to your project and update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/anilist_data/
```

**Required JSON files:**
- `viewer_data.json` - User profile and library data
- `home_data.json` - Trending anime data
- `search_results_naruto.json` - Search results
- `media_details_naruto.json` - Detailed anime information

### 4. Run the Prototype

**Option A: Standalone App**

```dart
import 'package:flutter/material.dart';
import 'expressive_anime/expressive_home.dart';

void main() {
  runApp(const ExpressiveApp());
}
```

**Option B: Add to Existing App**

```dart
import 'expressive_anime/expressive_home.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ExpressiveHomePage()),
);
```

**Option C: Use Individual Components**

```dart
import 'expressive_anime/widgets/manga_card.dart';
import 'expressive_anime/expressive_theme.dart';

// Use the design system
Container(
  decoration: ExpressiveTheme.mangaContainer(),
  child: Text('Hello', style: ExpressiveTheme.headlineLarge()),
)
```

### 5. Test It

```bash
flutter run
```

---

## 🎯 Key Features

### Home Screen
- Time-based greeting (Good morning/afternoon/evening)
- User profile avatar with stats dialog
- "Continue Watching" horizontal carousel with progress tracking
- "Trending Now" horizontal carousel
- Bottom navigation (Home, Explore, Library)

### Search/Explore Screen
- Real-time search with TextField
- Grid layout for results
- Skeleton loaders during data fetch
- Staggered pop-in animations

### Library Screen
- Tabbed interface (Watching, Planning, Completed, Dropped)
- Different card layouts per tab (horizontal for Watching, vertical for others)
- Staggered animations on load
- Empty state handling

### Anime Details Page
- Hero animations from cards
- Episode progress tracker with increment/decrement buttons
- "Add to List" dialog with list selection
- Synopsis, genres, studios, and metadata
- Character carousel (if available in data)
- Score display with custom star icons

### Reusable Widgets

**MangaCard** - Vertical card for grid/carousel layouts:
```dart
MangaCard(anime: animeObject)
```

**WatchingCard** - Horizontal card with progress indicator:
```dart
WatchingCard(
  entry: watchingEntry,
  progress: currentProgress,
  heroPrefix: 'home',
  onIncrement: () => updateProgress(),
)
```

**ExpressiveImage** - Image widget with skeleton loading:
```dart
ExpressiveImage(
  imageUrl: 'https://...',
  width: 180,
  height: 270,
  fit: BoxFit.cover,
)
```

**AnimeCardSkeleton** - Skeleton loader matching card dimensions:
```dart
AnimeCardSkeleton(isHorizontal: false)
```

---

## 🎨 Design System

All design tokens are centralized in `ExpressiveTheme`:

### Colors
```dart
ExpressiveTheme.primaryBlack    // Main text & borders
ExpressiveTheme.surfaceWhite    // Backgrounds
ExpressiveTheme.mangaRed        // Accent color (Colors.red[900])
ExpressiveTheme.indicatorGrey   // Navigation indicator
```

### Borders
```dart
ExpressiveTheme.borderWidthThin     // 2.0px
ExpressiveTheme.borderWidthMedium   // 3.0px
ExpressiveTheme.borderWidthThick    // 4.0px

ExpressiveTheme.thinBorder
ExpressiveTheme.mediumBorder
ExpressiveTheme.thickBorder
```

### Shadows
```dart
ExpressiveTheme.shadowOffsetSmall    // Offset(2, 2)
ExpressiveTheme.shadowOffsetMedium   // Offset(4, 4)
ExpressiveTheme.shadowOffsetLarge    // Offset(6, 6)

ExpressiveTheme.hardShadow(color: Colors.black, offset: ...)
ExpressiveTheme.hardShadows(...)  // Returns List<BoxShadow>
```

### Spacing
```dart
ExpressiveTheme.spacingXS    // 4.0
ExpressiveTheme.spacingS     // 8.0
ExpressiveTheme.spacingM     // 12.0
ExpressiveTheme.spacingL     // 16.0
ExpressiveTheme.spacingXL    // 24.0
ExpressiveTheme.spacingXXL   // 32.0
```

### Typography
```dart
ExpressiveTheme.headlineLarge()   // 42px, bold, Teko
ExpressiveTheme.headlineMedium()  // 36px, bold, Teko
ExpressiveTheme.titleLarge()      // 28px, italic, Teko
ExpressiveTheme.titleMedium()     // 24px, bold, Teko
ExpressiveTheme.cardTitle()       // 22px, bold, Teko
ExpressiveTheme.monoMedium()      // Roboto Mono for scores/numbers
ExpressiveTheme.label()           // 14px, bold, Teko
```

### Decorations
```dart
ExpressiveTheme.mangaContainer()      // Standard bordered container
ExpressiveTheme.avatarDecoration()    // Circular avatar with border
ExpressiveTheme.badgeDecoration()     // Chip/badge style
```

### Card Dimensions
```dart
ExpressiveTheme.cardWidth           // 180.0
ExpressiveTheme.cardHeight          // 280.0
ExpressiveTheme.watchingCardWidth   // 280.0
ExpressiveTheme.watchingCardHeight  // 180.0
ExpressiveTheme.avatarSize          // 56.0
```

---

## 🎬 Animations

All animations use `flutter_animate` for declarative, chainable effects:

```dart
widget
  .animate(delay: 100.ms)
  .fadeIn()
  .slideX(begin: 0.1, end: 0)
```

**Animation Patterns:**
- **Staggered delays**: First 6 items animate with `(index * 100).ms` delay, rest load instantly
- **Pop-in effect**: `fadeIn()` + `scale()` for cards
- **Slide-in**: `slideX()` for section titles
- **Hero transitions**: Between cards and detail page using `heroPrefix`

**Performance Tip:** Only the first 6 items in lists get staggered animations to avoid performance issues with long lists.

---

## 🔌 Connecting Your Own API

The prototype uses `MockDataService` which loads data from JSON assets. To connect a real API:

### Step 1: Create Your API Service

```dart
// lib/expressive_anime/services/your_api_service.dart
import '../models/anime.dart';
import '../models/user_profile.dart';
import 'mock_data_service.dart'; // For WatchingEntry class

class YourApiService {
  final String baseUrl = 'https://your-api.com';
  
  Future<UserProfile> getUserProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/user/profile'));
    return UserProfile.fromJson(jsonDecode(response.body));
  }
  
  Future<List<WatchingEntry>> getWatchingList() async {
    final response = await http.get(Uri.parse('$baseUrl/user/watching'));
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => WatchingEntry(
      id: e['id'],
      progress: e['progress'],
      userScore: e['score'],
      anime: Anime.fromJson(e['anime']),
    )).toList();
  }
  
  // Implement other methods...
}
```

### Step 2: Replace MockDataService

In these files, replace `MockDataService()` with `YourApiService()`:
- `expressive_home.dart`
- `screens/library_page.dart`
- `anime_details_page.dart`

### Required Methods

Your API service should implement:

```dart
Future<UserProfile> getUserProfile();
Future<List<WatchingEntry>> getWatchingList();
Future<Map<String, List<WatchingEntry>>> getLibraryLists();
Future<List<Anime>> getTrendingAnime();
Future<Anime?> getAnimeDetails(int id);
Future<List<Anime>> searchAnime(String query);
Future<List<String>> getAvailableListNames();
Future<WatchingEntry?> getMediaListEntry(int animeId);
Future<void> saveMediaListEntry(int animeId, String listName, int progress);
Future<void> updateEpisodeProgress(int animeId, int progress, int? totalEpisodes);
```

---

## ⚙️ Customization Guide

### Change Colors

Edit `expressive_theme.dart`:

```dart
// Lines 13-16
static const Color primaryBlack = Color(0xFF2C3E50);  // Dark blue
static const Color surfaceWhite = Color(0xFFFAFAFA);  // Off-white
static final Color mangaRed = Colors.teal[700]!;      // Teal accent
```

### Change Fonts

Edit text styles in `expressive_theme.dart`:

```dart
// Lines 171-177
static TextStyle headlineLarge({Color color = primaryBlack}) {
  return GoogleFonts.bebasNeue(  // Changed from 'teko'
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: color,
  );
}
```

### Adjust Card Sizes

Edit `expressive_theme.dart`:

```dart
// Lines 91-94
static const double cardWidth = 200.0;   // Wider cards
static const double cardHeight = 320.0;  // Taller cards
```

### Modify Animation Speed

Edit `expressive_theme.dart`:

```dart
// Lines 82-84
static const Duration animationFast = Duration(milliseconds: 150);
static const Duration animationMedium = Duration(milliseconds: 250);
```

### Adjust Shadow Offset

Edit `expressive_theme.dart`:

```dart
// Lines 45-49
static const Offset shadowOffsetMedium = Offset(6, 6);  // Larger shadow
```

---

## 📱 Adapting for Other Use Cases

### For a Movie/TV App

1. Rename models: `Anime` → `Movie`, `WatchingEntry` → `WatchlistEntry`
2. Update text: "Continue Watching" stays the same
3. Replace mock data with TMDB or similar API
4. Adjust card aspect ratios for movie posters

### For a Book Tracking App

1. Rename: `Anime` → `Book`, `episodes` → `chapters`
2. Update card layout for book covers (taller aspect ratio)
3. Replace progress tracker with page/chapter counter
4. Add reading status instead of watching status

### For a Game Library

1. Rename: `Anime` → `Game`, `episodes` → `achievements`
2. Update metadata chips for platforms/genres
3. Add playtime tracker instead of episode progress
4. Adjust card dimensions for game box art

---

## 🔧 Common Issues & Solutions

### Fonts not loading
**Solution:** Run `flutter pub get` and restart your app (hot restart, not hot reload).

### Images not loading
**Solution:** Check that `cached_network_image` is installed and images have valid URLs.

### Mock data not found
**Solution:** Verify `assets/anilist_data/` is in your project and listed in `pubspec.yaml`.

### Build errors after copying
**Solution:** Check import paths. All imports should start with `expressive_anime/` or be relative within the folder.

### Animations not working
**Solution:** Ensure `flutter_animate` is installed. Run `flutter clean && flutter pub get`.

---

## 🚀 Production Checklist

Before deploying to production:

- [ ] Replace `MockDataService` with real API calls
- [ ] Implement proper error handling and retry logic
- [ ] Add authentication and user session management
- [ ] Implement offline caching with `sqflite` or `hive`
- [ ] Add analytics tracking (Firebase, Mixpanel)
- [x] Optimize images with `flutter_image_compress`

- [ ] Add pull-to-refresh on lists
- [ ] Implement infinite scroll for search results
- [ ] Add accessibility labels and semantic widgets
- [ ] Test on multiple screen sizes and orientations
- [ ] Handle edge cases (no internet, empty states)
- [ ] Add proper loading and error states
- [ ] Implement deep linking for anime details
- [ ] Add share functionality
- [ ] Optimize bundle size and remove unused assets

---

## 🐛 Known Limitations

- **Mock Data Only**: Currently uses static JSON files
- **Limited Detail Pages**: Only Naruto and Naruto Shippuden have full detail data
- **No Persistence**: Progress updates don't persist between sessions
- **No Authentication**: No user login or account management
- **Single User**: Hardcoded to one user's data
- **No Real-Time Updates**: Data doesn't sync with external sources

All of these are easily replaceable by implementing a real API service.

---

## 📚 Additional Resources

- [Flutter Animate Documentation](https://pub.dev/packages/flutter_animate)
- [Google Fonts Package](https://pub.dev/packages/google_fonts)
- [Cached Network Image](https://pub.dev/packages/cached_network_image)
- [AniList GraphQL API](https://anilist.gitbook.io/anilist-apiv2-docs/) (for real API integration)

---

## 💡 Pro Tips

- **Keep the theme centralized**: All design changes should happen in `expressive_theme.dart`
- **Use the skeleton loaders**: They match card dimensions perfectly
- **Leverage Hero animations**: Already set up between cards and detail page
- **Stagger animations wisely**: First 6 items animate, rest load instantly for performance
- **Maintain the design language**: Hard borders, no blur, high contrast

---

## 📄 License

This prototype is provided as-is for educational and design reference purposes.

---

**Built with Flutter** 💙 | **Designed for Expression** 🎨
