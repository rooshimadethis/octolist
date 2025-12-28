# OctoList Project Structure

Quick reference guide to navigate the codebase.

## 📁 Directory Tree

```
lib/
├── 📱 screens/              UI screens (full pages)
│   ├── home_screen.dart           Main home page
│   ├── social_page.dart           Social feed page
│   ├── library_page.dart          User's anime library
│   ├── search_page.dart           Search interface
│   ├── anime_details_page.dart    Anime details view
│   └── web_view_page.dart         In-app browser
│
├── 🎨 widgets/              Reusable UI components
│   ├── 📱 Social Feed
│   │   ├── activity_card.dart
│   │   ├── activity_details_dialog.dart
│   │   ├── activity_reply_item.dart
│   │   └── liked_by_section.dart
│   │
│   ├── 🎬 Anime/Media
│   │   ├── watching_card.dart
│   │   ├── manga_card.dart
│   │   └── metadata_chip.dart
│   │
│   ├── 🎨 Theme & Visual
│   │   ├── user_accent_builder.dart
│   │   ├── pressable_card.dart
│   │   ├── expressive_image.dart
│   │   ├── expressive_vibe_image.dart
│   │   └── grain_overlay.dart
│   │
│   ├── 🎮 Interactive
│   │   ├── rating_slider.dart
│   │   ├── vibe_slider.dart
│   │   └── expressive_button.dart
│   │
│   ├── 🎭 Special Effects
│   │   ├── octopus_mascot.dart
│   │   ├── typewriter_text.dart
│   │   └── outlined_star.dart
│   │
│   └── 🏗️ Layout
│       ├── section_title.dart
│       ├── anime_card_skeleton.dart
│       └── user_profile_dialog.dart
│
├── 🔧 services/             Business logic & data
│   ├── anilist_service.dart       AniList API calls
│   ├── discussion_service.dart    Episode discussions
│   ├── image_color_service.dart   Avatar color extraction
│   ├── anime_store.dart           Central state management
│   ├── auth_service.dart          Authentication
│   └── mock_data_service.dart     Testing/dev data
│
├── 🌐 graphql/              GraphQL setup
│   ├── anilist_client.dart        GraphQL client config
│   └── queries.dart               All GraphQL queries
│
├── 🎨 theme/                Theme configuration
│   └── expressive_theme.dart      App theming system
│
├── 🛠️ utils/                Utility functions
│   ├── color_parser.dart          Color utilities
│   ├── greeting_helper.dart       Time-based greetings
│   ├── image_optimizer.dart       Image compression
│   ├── snackbar_helper.dart       Snackbar utilities
│   ├── vibe_level.dart            Vibe score utilities
│   └── vibe_text_helper.dart      Vibe-based text
│
└── 📦 models/               Data models
    ├── anime.dart                 Anime data model
    ├── user_profile.dart          User profile model
    └── watching_entry.dart        Library entry model
```

## 🗺️ Navigation Guide

### "I want to..."

#### Work with the Social Feed
- **View the feed** → `screens/social_page.dart`
- **Modify a post card** → `widgets/activity_card.dart`
- **Change the details dialog** → `widgets/activity_details_dialog.dart`
- **Update reply styling** → `widgets/activity_reply_item.dart`
- **Modify "liked by" section** → `widgets/liked_by_section.dart`

#### Fetch or Display Anime Data
- **Make API calls** → `services/anilist_service.dart`
- **Write GraphQL queries** → `graphql/queries.dart`
- **Display an anime card** → `widgets/watching_card.dart`
- **Show anime details** → `screens/anime_details_page.dart`

#### Work with User Authentication
- **Login/logout logic** → `services/auth_service.dart`
- **User state** → `services/anime_store.dart`
- **User profile display** → `widgets/user_profile_dialog.dart`

#### Customize Theming
- **App theme** → `theme/expressive_theme.dart`
- **Vibe slider** → `widgets/vibe_slider.dart`
- **User accent colors** → `widgets/user_accent_builder.dart`
- **Color extraction** → `services/image_color_service.dart`

#### Find Episode Discussions
- **Discussion logic** → `services/discussion_service.dart`
- **Discussion UI** → `screens/anime_details_page.dart` (Discuss Episode button)

#### Add Loading States
- **Skeleton loader** → `widgets/anime_card_skeleton.dart`

#### Work with Images
- **Optimized images** → `widgets/expressive_image.dart`
- **Image compression** → `utils/image_optimizer.dart`
- **Avatar colors** → `services/image_color_service.dart`

## 📖 Documentation Files

- **`lib/widgets/README.md`** - Complete widget reference
- **`lib/services/README.md`** - Complete service reference
- **`.gemini/social_cleanup_summary.md`** - Recent social code refactoring
- **`GEMINI.md`** - Project overview and context

## 🎯 File Naming Patterns

| Pattern | Meaning | Example |
|---------|---------|---------|
| `*_page.dart` | Full screen | `social_page.dart` |
| `*_screen.dart` | Full screen | `home_screen.dart` |
| `*_card.dart` | Card component | `activity_card.dart` |
| `*_dialog.dart` | Modal/dialog | `activity_details_dialog.dart` |
| `*_service.dart` | Business logic | `anilist_service.dart` |
| `*_builder.dart` | Builder pattern | `user_accent_builder.dart` |
| `*_helper.dart` | Utility functions | `snackbar_helper.dart` |
| `expressive_*` | Theme-aware | `expressive_image.dart` |

## 🚀 Quick Start

1. **New to the project?** Start with `GEMINI.md`
2. **Looking for a widget?** Check `lib/widgets/README.md`
3. **Need to fetch data?** Check `lib/services/README.md`
4. **Lost in the code?** Use this file!

## 💡 Tips

- **Use your IDE's "Go to File"** (Cmd/Ctrl + P) and type the widget/service name
- **Search by functionality** in the README files
- **Follow imports** to understand dependencies
- **Check the directory tree** above for visual navigation
