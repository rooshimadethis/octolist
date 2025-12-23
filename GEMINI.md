# OctoList Project Context

## Project Overview
OctoList is a Flutter application for tracking anime. It consumes the [AniList GraphQL API](https://graphql.anilist.co) to fetch data such as trending anime and search results.

## Tech Stack
- **Framework**: Flutter (Dart)
- **State Management / Data Fetching**: `graphql_flutter`
  - Uses `GraphQLProvider` at the root.
  - Uses `Query` widgets for fetching data in the UI.
  - `Hive` is used for caching (via `initHiveForFlutter`).

## Architecture & Conventions
- **Feature-first or Layer-first**: Currently simple layer-based.
  - `lib/graphql/`: Contains Client configuration (`client.dart`) and Queries (`queries.dart`).
  - `lib/screens/`: Contains UI screens (e.g., `home_screen.dart`).
- **Styling**: Material 3 (`useMaterial3: true`), `Colors.deepPurple` seed.

## API & Data Strategy
> [!WARNING]
> **Strict Rate Limit**: AniList allows **30 requests/minute**.
> - **Batching**: Home Page and User Library must be fetched in single batch requests.
> - **Search**: Input must be debounced (500ms+).
> - **Caching**: Use `Hive` to persist generic data (Home, Profile) and User Library.
> - **Pagination**: Avoid pagination for User Library (Fetch All Strategy).

### Core Data Convention (`MediaShort`)
All lists (Home, Search, Library) must use the standardized `MediaShort` fragment to prevent layout shifts.
- **Fields**: `id`, `title`, `coverImage`, `type`, `format`, `status`, `score`, `episodes`, `isAdult`.
- **Details Only**: `bannerImage`, `description`, `relations`, `recommendations`.

## Feature Roadmap

### Priority 1: Media Discovery & Search (Core)
- **Advanced Search**: Filters for `genre`, `year`, `season`, `format`, `status`.
- **Trending**: Seasonal trends
- **Details Page**: 
  - Rich data: `bannerImage`, `studios`, `relations`.
  - **Adult Content**: Allowed (no forced filtering).

### Priority 2: User Tracking & Profile
- **Library Sync**: One-shot fetch of all lists (Planning, Current, etc.).
- **Mutations**: `SaveMediaListEntry` for updating progress/score.
- **User Profile**: Dedicated page for Avatar, Stats (minutes watched), and Favorites.

### Priority 3: Global Discovery (Future)
- **Global Activity Feed**: Community-wide watching updates.

## Important Commands
- **Run**: `flutter run`
- **Test**: `flutter test`
