# 🐙 OctoList

A modern, expressive anime tracking app built with Flutter that connects to the AniList API. Track your anime, discover new shows, engage with the community, and find episode discussions—all with a unique "vibe-based" theming system.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

### 📺 Anime Tracking
- **Discover Trending Anime** - Browse what's popular right now
- **Advanced Search** - Find anime by title, genre, year, and more
- **Personal Library** - Track your watching, completed, and planned anime
- **Progress Tracking** - Update episodes watched and ratings
- **Rich Details** - View descriptions, characters, studios, and recommendations

### 🌐 Social Features
- **Global Activity Feed** - See what the community is posting about
- **Like & Comment** - Engage with posts and replies
- **User Profiles** - View user stats, avatars, and favorites
- **Dynamic Accent Colors** - Each user's avatar colors their interactions

### 💬 Episode Discussions
- **Multi-Platform Search** - Automatically finds discussions from:
  - MyAnimeList (via Jikan API)
  - AniList forums
  - Reddit (fallback)
  - Google search (fallback)
- **Waterfall Strategy** - Tries multiple sources to find the best discussion thread

### 🎨 Unique Theming
- **Vibe Score System** - Adjust the app's visual intensity (0.0 - 1.0)
- **Dynamic Colors** - Theme changes based on your mood
- **Expressive Design** - Bold, brutalist-inspired UI with grain overlays
- **Material 3** - Modern Flutter design system

## 🏗️ Architecture

```
lib/
├── screens/       # Full-page views (Home, Social, Library, etc.)
├── widgets/       # Reusable UI components
├── services/      # Business logic & API calls
├── graphql/       # GraphQL client & queries
├── theme/         # Theming system
├── models/        # Data models
└── utils/         # Helper functions
```

**Key Technologies:**
- **State Management**: Provider + GraphQL Flutter
- **API**: AniList GraphQL API
- **Caching**: Hive (local storage)
- **Image Optimization**: flutter_image_compress
- **Color Extraction**: palette_generator

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- An AniList account (for authentication)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/octolist.git
   cd octolist
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### AniList API Setup

OctoList uses the AniList GraphQL API. You'll need to:
1. Create an AniList account at [anilist.co](https://anilist.co)
2. The app handles OAuth authentication automatically

**Rate Limits**: AniList allows 30 requests/minute. The app uses caching and batching to stay within limits.

## 📚 Documentation

- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Visual directory tree and navigation guide
- **[lib/widgets/README.md](lib/widgets/README.md)** - Complete widget reference
- **[lib/services/README.md](lib/services/README.md)** - Service architecture guide
- **[GEMINI.md](GEMINI.md)** - Project context and conventions

## 🎯 Key Features Explained

### Vibe Score Theming
The app features a unique "vibe score" slider that dynamically adjusts:
- Color intensity and saturation
- Shadow offsets and depths
- Text styling and weights
- Overall visual "energy"

This creates a personalized experience that matches your mood!

### Smart Discussion Finding
When you want to discuss an episode, OctoList:
1. Checks MyAnimeList for official discussion threads
2. Falls back to AniList forums
3. Provides Reddit and Google search links as backups
4. All in a single tap!

### User Accent Colors
Each user's avatar is analyzed to extract dominant colors, which are then used to theme their:
- Like buttons
- Profile elements
- Social interactions

This creates a visually cohesive and personalized social experience.

## 🛠️ Development

### Code Quality
```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Format code
dart format .
```

### Project Conventions
- **Material 3** design system
- **Expressive theming** with vibe scores
- **GraphQL** for all API calls
- **Caching-first** strategy for performance
- **Batch requests** to respect rate limits

## 📱 Screenshots

> Add screenshots here showcasing:
> - Home screen with trending anime
> - Social feed
> - Anime details page
> - Vibe slider in action

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **[AniList](https://anilist.co)** - For the amazing GraphQL API
- **[Jikan](https://jikan.moe)** - For MyAnimeList API access
- **Flutter Community** - For excellent packages and support

## 📞 Contact

Project Link: [https://github.com/yourusername/octolist](https://github.com/yourusername/octolist)

---

Made with 💜 and Flutter
