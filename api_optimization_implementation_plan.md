# Api Optimization & Data Cementing Plan

## Goal Description
Optimize AniList API usage (limit: **30 req/min**) and "cement" all data requirements for the Core & Tracking features.
**New Additions**: `SaveMediaListEntry` (Mutation) for tracking, and generic Search filters.

## User Review Required
> [!IMPORTANT]
> **Refined Scope**:
> - **Mutations**: We need to *write* data to track progress. Added `SaveMediaListEntry`.
> - **Advanced Search**: Added filters for `genre`, `year`, `season`.
> - **Strict Rate Limit**: 30 req/min strategy remains (batching).

## Data Requirements & Cementing

### Core Media Data (Fragment: `MediaShort`)
- **ID**: `id`
- **Titles**: `title { userPreferred, english }`
- **Images**: `coverImage { extraLarge, large, color }`
- **Metadata**: `type`, `format`, `status`, `averageScore`, `episodes`, `isAdult`

### Detailed Media Data
- All `MediaShort` Data
- **Visuals**: `bannerImage`, `streamingEpisodes`
- **Context**: `startDate`, `description`, `season`, `seasonYear`
- **Relations/Recs**: `relations`, `recommendations`
- **Studios**: `studios`

### User Profile Data
- **Identity**: `name`, `avatar`, `bannerImage`
- **Stats**: `count`, `minutesWatched`, `meanScore`
- **Lists**: `statuses` counts
- **Favourites**: `anime`, `characters`

## Proposed Changes

### `lib/graphql/`

#### [NEW] `lib/graphql/fragments.dart`
```dart
const String mediaFragment = """
  fragment MediaShort on Media {
    id
    title { userPreferred, english }
    coverImage { extraLarge, large, color }
    type
    format
    status(version: 2)
    averageScore
    episodes
    isAdult
  }
""";
```

#### [MODIFY] `lib/graphql/queries.dart`

**1. Home Page (Batch)**
```graphql
query GetHomeData {
  trending: Page(page: 1, perPage: 10) {
    media(sort: TRENDING_DESC, type: ANIME) { ...MediaShort }
  }
}
```

**2. User Viewer & Library (Unified Search/Profile/Library)**
Consolidates User settings, Statistics, and the entire Library into one request.
```graphql
query GetUserViewerData($name: String) {
  User(name: $name) {
    id
    name
    avatar { large }
    bannerImage
    statistics {
      anime {
        count
        minutesWatched
        episodesWatched
        meanScore
        statuses { count, status }
      }
    }
    mediaListOptions {
      scoreFormat
      rowOrder
      animeList {
        sectionOrder
        customLists
      }
    }
    favourites {
      anime {
        nodes { ...MediaShort }
      }
      characters {
        nodes {
          name { full }
          image { large }
        }
      }
    }
  }
  MediaListCollection(userName: $name, type: ANIME) {
    lists {
      name
      entries {
        id
        status
        score
        progress
        media { ...MediaShort }
      }
    }
  }
}
```

**4. Advanced Search**
Added filters: `$genre`, `$year`, `$season`.
```graphql
query SearchAnime($page: Int, $perPage: Int, $search: String, $sort: [MediaSort], $genre: String, $year: Int, $season: MediaSeason) {
  Page(page: $page, perPage: $perPage) {
    media(search: $search, sort: $sort, genre: $genre, seasonYear: $year, season: $season, type: ANIME) {
      ...MediaShort
    }
  }
}
```

**5. Details Query**
```graphql
query GetMediaDetails($id: Int) {
  Media(id: $id) {
    ...MediaShort
    bannerImage
    description
    startDate { year, month, day }
    season
    seasonYear
    studios(isMain: true) { nodes { name } }
    streamingEpisodes { title, thumbnail, url }
    relations {
      edges { relationType, node { ...MediaShort } }
    }
    recommendations(perPage: 7, sort: RATING_DESC) {
       nodes { mediaRecommendation { ...MediaShort } }
    }
  }
}
```

#### [NEW] `lib/graphql/mutations.dart`
**1. Update List Entry**
For updating episodes watched, score, or status.
```graphql
mutation SaveMediaListEntry($id: Int, $mediaId: Int, $status: MediaListStatus, $score: Float, $progress: Int, $startedAt: FuzzyDateInput, $completedAt: FuzzyDateInput) {
  SaveMediaListEntry(id: $id, mediaId: $mediaId, status: $status, score: $score, progress: $progress, startedAt: $startedAt, completedAt: $completedAt) {
    id
    status
    score
    progress
    startedAt { year month day }
    completedAt { year month day }
  }
}

  **2. Delete List Entry**
  ```graphql
  mutation DeleteMediaListEntry($id: Int) {
    DeleteMediaListEntry(id: $id) {
      deleted
    }
  }
  ```
```

## List Management & Sync Strategy

### 1. Source of Truth (Startup)
We fetch **one massive batch** when the app starts. This is our "Single Source of Truth".
*   **Query**: `Viewer` (Current User) + `MediaListCollection`.
*   **Data**: `Viewer.mediaListOptions` gives us definitions of all lists (including empty custom ones) to populate "Move to..." menus.

### 2. In-Memory State & Optimistic Updates
The app runs off a local "Cache-First" database (Hive/Provider).
*   **Moving Shows**: When a user moves a show (Planning -> Watching):
    1.  **API**: Fire `SaveMediaListEntry`.
    2.  **Local**: *Immediately* move the item in the local `MediaListCollection`.
    3.  **Result**: Instant UI update. No re-fetch needed.

### 3. External Synchronization (Website vs App)
If the user modifies their list on the AniList website:
*   **Startup**: We always fetch fresh data on app launch.
*   **Manual**: User must **Pull-to-Refresh** on the Library screen to sync external changes.
*   **Background**: We do *not* auto-poll due to the 30 req/min limit. Trust the local state until the user explicitly refreshes.

## Optimization Strategy
- **Batching**: Home, Library = 1 req each.
- **Mutations**: Only fire when user explicitly saves. Optimistic UI updates recommended.
- **Cache**: Hive.

## Verification
- **Test**: `SaveMediaListEntry` updates the local cache/UI correctly.
- **Test**: Search filters (`year`, `genre`) return filtered results.
