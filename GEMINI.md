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

## Feature Roadmap

### Priority 1: Media Discovery & Search (Core)
- **Advanced Search**: Genre, tags, year, season, format, status filters.
- **Trending & Popular**: Seasonal trends and all-time popular media.
- **Details Page**: Descriptions, countdowns, relations, studios, recommendations, and reviews.

### Priority 2: User List Management (Tracking)
- **Personal List Sync**: View Current, Planning, Completed, etc.
- **Progress Updates**: Episode increments, status changes, and scoring.

### Priority 3: Global Discovery (Future)
- **Global Activity Feed**: Community-wide watching updates.

## Important Commands
- **Run**: `flutter run`
- **Test**: `flutter test`

## Development Preferences
> [!IMPORTANT]
> **Hands-On Approach**: The user wants to be hands-on.
> - **DO NOT** write any code unless the user specifically asks for it.
> - **DO** provide clear instructions, tutorials, and complete code snippets in the implementation plans.
> - **DO** explain *how* to implement something and let the user write the code where possible, or ask for permission before writing large chunks.
> - **DO** focus on *teaching* and *guiding*.
