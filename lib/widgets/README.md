# Widgets Directory

This directory contains all reusable UI components for the OctoList app.

## 📱 Social Feed Widgets

### `activity_card.dart`
**Purpose**: Displays a single activity post in the social feed list  
**Used in**: `social_page.dart`  
**Key features**:
- Shows user avatar, name, timestamp
- Displays post text with HTML rendering
- Shows like/reply counts
- Pressable with animation (uses `PressableCard`)
- User-specific accent colors (uses `UserAccentBuilder`)

### `activity_details_dialog.dart`
**Purpose**: Full-screen dialog showing a post with all replies and interactions  
**Used in**: `social_page.dart` (when tapping an activity card)  
**Key features**:
- Shows full post content
- "Liked by" section with user avatars
- Like/unlike post functionality
- Add comments/replies
- List of all replies with like buttons
- Uses `LikedBySection` and `ActivityReplyItem` widgets

### `activity_reply_item.dart`
**Purpose**: Single reply/comment in an activity thread  
**Used in**: `activity_details_dialog.dart`  
**Key features**:
- User avatar and name
- Reply text with HTML rendering
- Like button with count
- User-specific accent colors

### `liked_by_section.dart`
**Purpose**: Horizontal scrollable list of users who liked a post  
**Used in**: `activity_details_dialog.dart`  
**Key features**:
- Shows up to 10 user avatars
- User names on hover/tooltip
- Displays total like count

## 🎨 Theme & Visual Widgets

### `user_accent_builder.dart`
**Purpose**: Extracts and provides user-specific accent colors from avatars  
**Used in**: `activity_card.dart`, `activity_details_dialog.dart`, `activity_reply_item.dart`  
**Key features**:
- Extracts dominant color from user avatar
- Falls back to AniList profile color
- Caches colors for performance
- Provides color to child widgets via builder pattern

### `pressable_card.dart`
**Purpose**: Reusable wrapper that adds press animation and haptic feedback  
**Used in**: `activity_card.dart`, potentially other cards  
**Key features**:
- Smooth press-down animation
- Haptic feedback on press/release
- Configurable shadow offset and timing
- Builder pattern for dynamic styling

### `expressive_image.dart`
**Purpose**: Optimized image loading with caching and compression  
**Used in**: Throughout the app for all images  
**Key features**:
- Automatic image compression
- Caching for performance
- Loading placeholders
- Error handling

### `expressive_vibe_image.dart`
**Purpose**: Image component that responds to the app's "vibe score"  
**Used in**: Home screen and themed pages  
**Key features**:
- Dynamic styling based on vibe
- Animated transitions

### `grain_overlay.dart`
**Purpose**: Adds a film grain texture overlay for aesthetic effect  
**Used in**: Various screens for visual style  

## 📺 Anime/Media Widgets

### `watching_card.dart`
**Purpose**: Displays an anime in the user's watching list  
**Used in**: `library_page.dart`  
**Key features**:
- Cover image
- Title and progress
- Rating display
- Quick actions

### `manga_card.dart`
**Purpose**: Displays a manga entry  
**Used in**: Search results, library  

### `metadata_chip.dart`
**Purpose**: Small chip showing metadata (genre, year, status, etc.)  
**Used in**: Anime details page  

## 🎮 Interactive Widgets

### `rating_slider.dart`
**Purpose**: Custom slider for rating anime  
**Used in**: Anime details page, library  
**Key features**:
- Visual rating scale
- Haptic feedback
- Expressive styling

### `vibe_slider.dart`
**Purpose**: Controls the app's "vibe score" theme  
**Used in**: Home screen  
**Key features**:
- Changes app-wide theme
- Animated transitions
- Persistent setting

### `expressive_button.dart`
**Purpose**: Themed button component  
**Used in**: Throughout the app  
**Key features**:
- Consistent styling
- Vibe-aware colors
- Haptic feedback

## 🎭 Special Effect Widgets

### `octopus_mascot.dart`
**Purpose**: Animated octopus mascot character  
**Used in**: Home screen, empty states  

### `typewriter_text.dart`
**Purpose**: Text that animates in character-by-character  
**Used in**: Greetings, special messages  

### `outlined_star.dart`
**Purpose**: Custom star icon for ratings  
**Used in**: Rating displays  

## 🏗️ Layout Widgets

### `section_title.dart`
**Purpose**: Consistent section headers throughout the app  
**Used in**: Home, library, details pages  

### `anime_card_skeleton.dart`
**Purpose**: Loading placeholder for anime cards  
**Used in**: All pages with loading states  
**Key features**:
- Shimmer animation
- Matches card dimensions
- Smooth transitions

## 📱 Dialog Widgets

### `user_profile_dialog.dart`
**Purpose**: Shows user profile information  
**Used in**: Tapping user avatars  
**Key features**:
- User stats
- Avatar and name
- Favorites

---

## 🔍 Quick Reference

**Need to show a social post?** → `activity_card.dart`  
**Need post details with replies?** → `activity_details_dialog.dart`  
**Need user-specific colors?** → `user_accent_builder.dart`  
**Need press animation?** → `pressable_card.dart`  
**Need to show an image?** → `expressive_image.dart`  
**Need a loading state?** → `anime_card_skeleton.dart`  
**Need to show an anime?** → `watching_card.dart`  

## 📝 Naming Conventions

- `*_card.dart` - Card-style components for displaying items
- `*_dialog.dart` - Full-screen or modal dialogs
- `*_builder.dart` - Builder pattern widgets that provide data/styling to children
- `expressive_*.dart` - Theme-aware components that respond to vibe score
- `*_skeleton.dart` - Loading placeholder components
