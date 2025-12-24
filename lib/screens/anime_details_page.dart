import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../models/anime.dart';
import '../services/anime_service_interface.dart';
import '../services/anime_store.dart';
import '../widgets/expressive_image.dart';
import '../widgets/outlined_star.dart';
import '../widgets/metadata_chip.dart';
import '../utils/color_parser.dart';
import '../theme/expressive_theme.dart';
import '../widgets/grain_overlay.dart';

class AnimeDetailsPage extends StatefulWidget {
  final Anime anime;

  const AnimeDetailsPage({super.key, required this.anime});

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  late Future<Anime?> _fullDetailsFuture;
  late IAnimeService _animeService;
  late ConfettiController _confettiController;
  bool _isUpdating = false;

  // Store initial animation values so they don't change during rebuilds
  late final Duration _entranceDuration;
  late final Curve _entranceCurve;

  @override
  void initState() {
    super.initState();
    _animeService = context.read<AnimeStore>().service;
    _fullDetailsFuture = _animeService.getAnimeDetails(widget.anime.id);

    // Capture initial vibe for stable entrance animations
    final initialVibe = context.read<AnimeStore>().vibeScore;
    _entranceDuration = ExpressiveTheme.vibeDuration(initialVibe);
    _entranceCurve = ExpressiveTheme.vibeCurve(initialVibe);

    // Defer the snackbar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading details...'),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.black,
          ),
        );
      }
    });
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Show dialog to select which list to add the anime to
  Future<void> _showListSelectionDialog(
    Anime anime,
    String? currentList,
    double vibeScore,
  ) async {
    final listNames = await _animeService.getAvailableListNames();

    if (!mounted) return;

    final primaryText = ExpressiveTheme.getPrimaryText(vibeScore);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: scaffoldBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: primaryText, width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: primaryText, width: 3),
            boxShadow: [
              BoxShadow(
                color: ExpressiveTheme.getShadowColor(vibeScore),
                offset: ExpressiveTheme.getShadowOffset(vibeScore),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryText,
                  border: Border(
                    bottom: BorderSide(color: primaryText, width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ADD TO LIST',
                        style: GoogleFonts.teko(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: scaffoldBg,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: scaffoldBg),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // List options
              ListView.separated(
                shrinkWrap: true,
                itemCount: listNames.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, thickness: 2, color: primaryText),
                itemBuilder: (context, index) {
                  final listName = listNames[index];
                  final isCurrentList = listName == currentList;

                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      _updateListStatus(anime, listName, vibeScore);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: isCurrentList
                          ? primaryText.withValues(alpha: 0.1)
                          : scaffoldBg,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              listName.toUpperCase(),
                              style: GoogleFonts.teko(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                            ),
                          ),
                          if (isCurrentList)
                            Icon(Icons.check, color: primaryText),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Update the list status for the anime
  Future<void> _updateListStatus(
    Anime anime,
    String listName,
    double vibeScore,
  ) async {
    setState(() => _isUpdating = true);
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adding to $listName...'),
            duration: const Duration(milliseconds: 500),
            backgroundColor: ExpressiveTheme.getPrimaryText(vibeScore),
          ),
        );
      }

      await context.read<AnimeStore>().saveToStatus(anime.id, listName);

      if (mounted) {
        setState(() => _isUpdating = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to $listName!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update list: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Update episode progress with delta (+1 or -1)
  Future<void> _updateEpisodeProgress(
    Anime anime,
    int delta,
    double vibeScore,
  ) async {
    try {
      if (delta > 0) {
        _confettiController.play();
      }

      await context.read<AnimeStore>().updateProgress(anime.id, delta);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Progress saved!'),
            duration: const Duration(milliseconds: 500),
            backgroundColor: ExpressiveTheme.getPrimaryText(vibeScore),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save progress: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse color or use default black for Manga style
    // final primaryColor = widget.anime.color != null
    //     ? Color(int.parse(widget.anime.color!.replaceAll('#', '0xFF')))
    //     : Colors.black;

    return Consumer<AnimeStore>(
      builder: (context, store, _) {
        final entry = store.getEntry(widget.anime.id);
        final currentEpisode = entry?.progress ?? 0;

        // Determine current list name from store
        String? currentListName;
        for (var listName in store.listNames) {
          if (store
              .getListEntries(listName)
              .any((e) => e.anime.id == widget.anime.id)) {
            currentListName = listName;
            break;
          }
        }

        final vibeScore = store.vibeScore;
        final primaryText = ExpressiveTheme.getPrimaryText(vibeScore);
        final shadowOffset = ExpressiveTheme.getShadowOffset(vibeScore);
        final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: Stack(
            children: [
              FutureBuilder<Anime?>(
                future: _fullDetailsFuture,
                builder: (context, snapshot) {
                  final anime = snapshot.data ?? widget.anime;
                  final shadowColor = ColorParser.parseAnimeColor(anime.color);
                  final dynamicShadowColor = ExpressiveTheme.getShadowColor(
                    vibeScore,
                    anime.parsedColor,
                  );

                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight:
                            300, // Increased height for the covering effect
                        pinned: true,
                        stretch: true,
                        backgroundColor: primaryText,
                        leading: _PressableBackButton(
                          vibeScore: vibeScore,
                          parsedColor: anime.parsedColor,
                          onPressed: () => Navigator.pop(context),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          stretchModes: const [
                            StretchMode.zoomBackground,
                            StretchMode.blurBackground,
                          ],
                          background: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Banner Background
                              if (anime.bannerImage != null ||
                                  anime.coverImage != null)
                                ColorFiltered(
                                  colorFilter: const ColorFilter.mode(
                                    Colors
                                        .grey, // Desaturate banner to make cover pop
                                    BlendMode.saturation,
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.3),
                                          Colors.black.withValues(alpha: 0.8),
                                        ],
                                      ).createShader(rect);
                                    },
                                    blendMode: BlendMode.srcOver,
                                    child: ExpressiveImage(
                                      imageUrl:
                                          anime.bannerImage ?? anime.coverImage,
                                      fit: BoxFit.cover,
                                      skeletonColor: anime.parsedColor,
                                    ),
                                  ),
                                )
                              else
                                Container(color: Colors.black),

                              // Decoration / Border
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: primaryText,
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),

                              // Hovering Cover Image
                              Positioned(
                                bottom: 40,
                                child: Hero(
                                  tag: 'anime_cover_${anime.id}',
                                  child: Container(
                                    width: 180, // Larger Poster size
                                    height: 270,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ExpressiveTheme.getShadowColor(
                                            vibeScore,
                                            anime.parsedColor,
                                          ),
                                          offset:
                                              ExpressiveTheme.getShadowOffset(
                                                vibeScore,
                                              ),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        final filter =
                                            ExpressiveTheme.getImageFilter(
                                              vibeScore,
                                            );
                                        final image = ExpressiveImage(
                                          imageUrl: anime.coverImage,
                                          fit: BoxFit.cover,
                                          skeletonColor: anime.parsedColor,
                                        );

                                        if (filter == null) return image;

                                        return Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ColorFiltered(
                                              colorFilter: filter,
                                              child: image,
                                            ),
                                            GrainOverlay(
                                              opacity:
                                                  ExpressiveTheme.getGrainOpacity(
                                                    vibeScore,
                                                  ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: BoxDecoration(
                            color: scaffoldBg,
                            // No rounded top, maybe just a hard separation
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title and Score
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child:
                                                Text(
                                                      anime.title.toUpperCase(),
                                                      style: GoogleFonts.teko(
                                                        fontSize: 42,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 0.9,
                                                        color: primaryText,
                                                      ),
                                                    )
                                                    .animate()
                                                    .fadeIn(
                                                      duration:
                                                          _entranceDuration,
                                                    )
                                                    .slideY(
                                                      begin: 0.2,
                                                      end: 0,
                                                      duration:
                                                          _entranceDuration,
                                                      curve: _entranceCurve,
                                                    ),
                                          ),
                                          if (anime.averageScore != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: scaffoldBg,
                                                border: Border.all(
                                                  color: primaryText,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        ExpressiveTheme.getShadowColor(
                                                          vibeScore,
                                                          anime.parsedColor,
                                                        ),
                                                    offset:
                                                        ExpressiveTheme.getShadowOffset(
                                                          vibeScore,
                                                        ) /
                                                        2,
                                                    blurRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  OutlinedStar(
                                                    size: 18,
                                                    color: primaryText,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${anime.averageScore}%',
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: primaryText,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ).animate().scale(
                                              delay: 200.ms,
                                              duration: _entranceDuration,
                                              curve: _entranceCurve,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Metadata Pills
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (anime.season != null &&
                                              anime.seasonYear != null)
                                            MetadataChip(
                                              label:
                                                  '${anime.season} ${anime.seasonYear}',
                                              icon:
                                                  Icons.calendar_today_rounded,
                                              shadowColor: shadowColor,
                                            ),
                                          if (anime.status != null)
                                            MetadataChip(
                                              label: anime.status!,
                                              icon: Icons.info_outline_rounded,
                                              shadowColor: shadowColor,
                                            ),
                                          if (anime.studios.isNotEmpty)
                                            MetadataChip(
                                              label: anime.studios.first.name,
                                              icon: Icons.business_rounded,
                                              shadowColor: shadowColor,
                                            ),
                                          if (anime.episodes != null)
                                            MetadataChip(
                                              label:
                                                  '${anime.episodes} Episodes',
                                              icon: Icons.movie_filter_rounded,
                                              shadowColor: shadowColor,
                                            ),
                                          ...anime.genres
                                              .take(3)
                                              .map(
                                                (genre) => MetadataChip(
                                                  label: genre,
                                                  icon: Icons.tag_rounded,
                                                  shadowColor: shadowColor,
                                                ),
                                              ),
                                        ],
                                      ).animate().fadeIn(
                                        delay: 300.ms,
                                        duration: _entranceDuration,
                                      ),
                                      const SizedBox(height: 24),
                                      // Action Button
                                      SizedBox(
                                        width: double.infinity,
                                        child:
                                            ElevatedButton.icon(
                                              onPressed: _isUpdating
                                                  ? null
                                                  : () {
                                                      HapticFeedback.lightImpact();
                                                      _showListSelectionDialog(
                                                        anime,
                                                        currentListName,
                                                        vibeScore,
                                                      );
                                                    },
                                              icon: Icon(
                                                currentListName == null
                                                    ? Icons.add
                                                    : Icons.check,
                                                color: Colors.white,
                                              ),
                                              label: Text(
                                                currentListName == null
                                                    ? 'ADD TO LIST'
                                                    : currentListName
                                                          .toUpperCase(),
                                                style: GoogleFonts.teko(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryText,
                                                foregroundColor: scaffoldBg,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.zero,
                                                  side: BorderSide(
                                                    color: primaryText,
                                                    width: 3,
                                                  ),
                                                ),
                                                disabledBackgroundColor:
                                                    Colors.grey,
                                              ),
                                            ).animate().shimmer(
                                              delay: 1000.ms,
                                              duration: 1200.ms,
                                            ),
                                      ),
                                      const SizedBox(height: 24),
                                      // Episode Tracker
                                      if (anime.episodes != null) ...[
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: scaffoldBg,
                                            border: Border.all(
                                              color: primaryText,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: dynamicShadowColor
                                                    .withValues(alpha: 0.5),
                                                offset: shadowOffset,
                                                blurRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'EPISODE PROGRESS',
                                                    style: GoogleFonts.teko(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: primaryText,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$currentEpisode / ${anime.episodes}',
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: primaryText,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              // Progress Bar
                                              Container(
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: primaryText,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      color: scaffoldBg,
                                                    ),
                                                    FractionallySizedBox(
                                                      widthFactor:
                                                          anime.episodes! > 0
                                                          ? currentEpisode /
                                                                anime.episodes!
                                                          : 0,
                                                      child: Container(
                                                        color: primaryText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              // +/- Buttons
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed:
                                                          currentEpisode <= 0
                                                          ? null
                                                          : () {
                                                              HapticFeedback.mediumImpact();
                                                              _updateEpisodeProgress(
                                                                anime,
                                                                -1,
                                                                vibeScore,
                                                              );
                                                            },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            scaffoldBg,
                                                        foregroundColor:
                                                            primaryText,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 12,
                                                            ),
                                                        elevation: 0,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero,
                                                              side: BorderSide(
                                                                color:
                                                                    primaryText,
                                                                width: 2,
                                                              ),
                                                            ),
                                                        disabledBackgroundColor:
                                                            Colors.grey
                                                                .withValues(
                                                                  alpha: 0.3,
                                                                ),
                                                      ),
                                                      child: Text(
                                                        '-',
                                                        style: GoogleFonts.teko(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed:
                                                          currentEpisode >=
                                                              anime.episodes!
                                                          ? null
                                                          : () {
                                                              HapticFeedback.mediumImpact();
                                                              _updateEpisodeProgress(
                                                                anime,
                                                                1,
                                                                vibeScore,
                                                              );
                                                            },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            dynamicShadowColor,
                                                        foregroundColor:
                                                            ExpressiveTheme.getContrastText(
                                                              dynamicShadowColor,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 12,
                                                            ),
                                                        elevation: 0,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero,
                                                              side: BorderSide(
                                                                color:
                                                                    primaryText,
                                                                width: 2,
                                                              ),
                                                            ),
                                                        disabledBackgroundColor:
                                                            Colors.grey,
                                                      ),
                                                      child: Text(
                                                        '+',
                                                        style: GoogleFonts.teko(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                      // Synopsis
                                      Text(
                                        'SYNOPSIS',
                                        style: GoogleFonts.teko(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: primaryText,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: primaryText,
                                              width: 4,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          anime.description?.replaceAll(
                                                '<br>',
                                                '\n',
                                              ) ??
                                              "No description available.",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: primaryText.withValues(
                                                  alpha: 0.8,
                                                ),
                                                height: 1.5,
                                                fontFamily:
                                                    GoogleFonts.robotoMono()
                                                        .fontFamily,
                                              ),
                                        ).animate().fadeIn(delay: 400.ms),
                                      ),
                                    ],
                                  ),
                                ),
                                // Characters Section
                                if (anime.characters.isNotEmpty) ...[
                                  const SizedBox(height: 32),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                    ),
                                    child: Text(
                                      'CHARACTERS',
                                      style: GoogleFonts.teko(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: primaryText,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 180, // Taller for square cards
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: anime.characters.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 16),
                                      itemBuilder: (context, index) {
                                        final character =
                                            anime.characters[index];
                                        return Column(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: scaffoldBg,
                                                border: Border.all(
                                                  color: primaryText,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        ExpressiveTheme.getShadowColor(
                                                          vibeScore,
                                                        ),
                                                    offset: const Offset(4, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ExpressiveImage(
                                                imageUrl: character.image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              character.name
                                                  .split(' ')
                                                  .first
                                                  .toUpperCase(),
                                              style: GoogleFonts.teko(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: primaryText,
                                              ),
                                            ),
                                            Text(
                                              character.role.toUpperCase(),
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: primaryText.withValues(
                                                  alpha: 0.7,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                // Relations Section
                                if (anime.relations.isNotEmpty) ...[
                                  const SizedBox(height: 32),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                    ),
                                    child: Text(
                                      'RELATIONS',
                                      style: GoogleFonts.teko(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: primaryText,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 240,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: anime.relations.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 16),
                                      itemBuilder: (context, index) {
                                        final relation = anime.relations[index];
                                        final relAnime = relation.anime;
                                        return _PressableVerticalCard(
                                          title: relAnime.title,
                                          imageUrl: relAnime.coverImage ?? '',
                                          parsedColor: relAnime.parsedColor,
                                          vibeScore: vibeScore,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AnimeDetailsPage(
                                                      anime: relAnime,
                                                    ),
                                              ),
                                            );
                                          },
                                          overlay: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryText,
                                              borderRadius: BorderRadius.zero,
                                            ),
                                            child: Text(
                                              relation.relationType
                                                  .replaceAll('_', ' ')
                                                  .toUpperCase(),
                                              style: GoogleFonts.teko(
                                                color: scaffoldBg,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ], // Recommendations Section
                                if (anime.recommendations.isNotEmpty) ...[
                                  const SizedBox(height: 32),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                    ),
                                    child: Text(
                                      'RECOMMENDATIONS',
                                      style: GoogleFonts.teko(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: primaryText,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 240,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: anime.recommendations.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 16),
                                      itemBuilder: (context, index) {
                                        final rec =
                                            anime.recommendations[index];
                                        return _PressableVerticalCard(
                                          title: rec.title,
                                          imageUrl: rec.coverImage ?? '',
                                          parsedColor: rec.parsedColor,
                                          vibeScore: vibeScore,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AnimeDetailsPage(
                                                      anime: rec,
                                                    ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Confetti overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3.14 / 2, // downward
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.03,
                  numberOfParticles: 30,
                  gravity: 0.3,
                  shouldLoop: false,
                  maxBlastForce: 20,
                  minBlastForce: 10,
                  colors: const [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.pink,
                    Colors.purple,
                    Colors.orange,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PressableVerticalCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final Color parsedColor;
  final double vibeScore;
  final VoidCallback onTap;
  final Widget? overlay;

  const _PressableVerticalCard({
    required this.title,
    required this.imageUrl,
    required this.parsedColor,
    required this.vibeScore,
    required this.onTap,
    this.overlay,
  });

  @override
  State<_PressableVerticalCard> createState() => _PressableVerticalCardState();
}

class _PressableVerticalCardState extends State<_PressableVerticalCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryText = ExpressiveTheme.getPrimaryText(widget.vibeScore);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final shadowColor = ExpressiveTheme.getShadowColor(widget.vibeScore);
    final shadowOffset = const Offset(4, 4);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () async {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) setState(() => _isPressed = false);
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted) {
          widget.onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutQuad,
        transform: Matrix4.translationValues(
          _isPressed ? shadowOffset.dx : 0,
          _isPressed ? shadowOffset.dy : 0,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    color: scaffoldBg,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: primaryText, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        offset: _isPressed ? Offset.zero : shadowOffset,
                      ),
                    ],
                  ),
                  child: ExpressiveImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    skeletonColor: widget.parsedColor,
                  ),
                ),
                if (widget.overlay != null)
                  Positioned(top: 0, left: 0, child: widget.overlay!),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 100, // Matching the image width
              child: Text(
                widget.title.toUpperCase(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.teko(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableBackButton extends StatefulWidget {
  final double vibeScore;
  final Color parsedColor;
  final VoidCallback onPressed;

  const _PressableBackButton({
    required this.vibeScore,
    required this.parsedColor,
    required this.onPressed,
  });

  @override
  State<_PressableBackButton> createState() => _PressableBackButtonState();
}

class _PressableBackButtonState extends State<_PressableBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryText = ExpressiveTheme.getPrimaryText(widget.vibeScore);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final shadowColor = ExpressiveTheme.getShadowColor(
      widget.vibeScore,
      widget.parsedColor,
    );
    final shadowOffset = const Offset(2, 2);

    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () async {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) setState(() => _isPressed = false);
          await Future.delayed(const Duration(milliseconds: 50));
          if (context.mounted) {
            widget.onPressed();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutQuad,
          margin: const EdgeInsets.all(8),
          transform: Matrix4.translationValues(
            _isPressed ? shadowOffset.dx : 0,
            _isPressed ? shadowOffset.dy : 0,
            0,
          ),
          decoration: BoxDecoration(
            color: scaffoldBg,
            border: Border.all(color: primaryText, width: 2),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: _isPressed ? Offset.zero : shadowOffset,
                blurRadius: 0,
              ),
            ],
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.arrow_back_rounded, color: primaryText),
          ),
        ),
      ),
    );
  }
}
