# Services Directory

This directory contains all business logic, data fetching, and state management services.

## 🌐 API & Data Services

### `anilist_service.dart`
**Purpose**: Handles all AniList API interactions  
**Used by**: Screens and widgets that need anime data  
**Key responsibilities**:
- Fetch trending anime
- Search anime
- Get anime details
- Fetch user library
- Update watch progress
- Save ratings

**Key methods**:
```dart
Future<List<Anime>> getTrendingAnime()
Future<List<Anime>> searchAnime(String query)
Future<Anime> getAnimeDetails(int id)
Future<void> updateProgress(int mediaId, int progress)
```

### `discussion_service.dart`
**Purpose**: Finds episode discussion threads across multiple platforms  
**Used by**: `anime_details_page.dart` (Discuss Episode feature)  
**Key responsibilities**:
- Search MyAnimeList for episode discussions
- Search AniList for episode discussions
- Generate fallback search URLs (Reddit, Google)
- Waterfall strategy: tries Jikan → AniList → Fallbacks

**Key methods**:
```dart
Future<List<DiscussionOption>> findEpisodeDiscussions(
  int anilistId,
  int? malId,
  String title,
  int episodeNumber,
)
```

### `image_color_service.dart`
**Purpose**: Extracts dominant colors from images (especially user avatars)  
**Used by**: `user_accent_builder.dart`  
**Key responsibilities**:
- Extract vibrant/dominant colors from network images
- Cache extracted colors to avoid redundant processing
- Deduplicate simultaneous extraction requests
- Fast color extraction (low color count for speed)

**Key methods**:
```dart
static Future<Color?> extractDominantColor(String imageUrl)
static Color? getCachedColor(String imageUrl)
```

**Performance notes**:
- Uses `palette_generator` package
- Caches results in memory
- Prevents duplicate extractions with pending futures map

## 🗄️ State Management

### `anime_store.dart`
**Purpose**: Central state management for the entire app  
**Used by**: All screens via `Provider`  
**Key responsibilities**:
- Manages vibe score (theme state)
- Stores user profile data
- Caches anime lists
- Manages authentication state
- Persists settings

**Key properties**:
```dart
double vibeScore          // Current theme vibe (0.0 - 1.0)
UserProfile? userProfile  // Logged-in user data
bool isAuthenticated      // Auth status
```

**Key methods**:
```dart
void setVibeScore(double score)
Future<void> loadUserProfile()
Future<void> logout()
```

## 🔐 Authentication

### `auth_service.dart`
**Purpose**: Handles AniList OAuth authentication  
**Used by**: Login flow, `anime_store.dart`  
**Key responsibilities**:
- OAuth flow with AniList
- Token storage and retrieval
- Token validation
- Logout functionality

**Key methods**:
```dart
Future<String?> login()
Future<void> logout()
Future<String?> getToken()
bool isAuthenticated()
```

## 🧪 Development & Testing

### `mock_data_service.dart`
**Purpose**: Provides mock data for development and testing  
**Used by**: Development builds, tests  
**Key responsibilities**:
- Generate fake anime data
- Mock API responses
- Testing utilities

### `anime_service_interface.dart`
**Purpose**: Interface/contract for anime services  
**Used by**: Service implementations  
**Key responsibilities**:
- Defines service contract
- Enables dependency injection
- Allows for mock implementations

---

## 🔍 Quick Reference

**Need to fetch anime data?** → `anilist_service.dart`  
**Need to find episode discussions?** → `discussion_service.dart`  
**Need user avatar colors?** → `image_color_service.dart`  
**Need app-wide state?** → `anime_store.dart`  
**Need to authenticate?** → `auth_service.dart`  
**Need mock data?** → `mock_data_service.dart`  

## 🏗️ Architecture Pattern

All services follow these principles:

1. **Single Responsibility**: Each service has one clear purpose
2. **Stateless (mostly)**: Services don't hold state; they provide data to `anime_store.dart`
3. **Async/Await**: All API calls use async/await pattern
4. **Error Handling**: Services throw exceptions; UI handles them
5. **Caching**: Services cache when appropriate (e.g., `image_color_service.dart`)

## 📊 Service Dependencies

```
┌─────────────────┐
│  anime_store    │ ← Central state (used by all screens)
└────────┬────────┘
         │
    ┌────┴────┬──────────┬─────────────┐
    │         │          │             │
┌───▼────┐ ┌─▼──────┐ ┌─▼─────────┐ ┌─▼──────────────┐
│anilist │ │  auth  │ │discussion │ │ image_color    │
│service │ │service │ │ service   │ │   service      │
└────────┘ └────────┘ └───────────┘ └────────────────┘
```

## 🎯 When to Create a New Service

Create a new service when you need to:
- Interact with a new external API
- Add complex business logic that doesn't fit existing services
- Extract reusable functionality used by multiple screens
- Manage a specific domain of data (e.g., notifications, bookmarks)

**Don't create a service for**:
- Simple utility functions → Use `utils/` directory
- UI-specific logic → Keep in widgets
- One-off calculations → Keep in the widget/screen
