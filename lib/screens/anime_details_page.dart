import 'dart:async';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _animeService = context.read<AnimeStore>().service;
    _fullDetailsFuture = _animeService.getAnimeDetails(widget.anime.id);

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
  ) async {
    final listNames = await _animeService.getAvailableListNames();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Colors.black, width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(8, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 3),
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
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
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
                    const Divider(height: 1, thickness: 2, color: Colors.black),
                itemBuilder: (context, index) {
                  final listName = listNames[index];
                  final isCurrentList = listName == currentList;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _updateListStatus(anime, listName);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: isCurrentList ? Colors.grey[200] : Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              listName.toUpperCase(),
                              style: GoogleFonts.teko(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (isCurrentList)
                            const Icon(Icons.check, color: Colors.black),
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
  Future<void> _updateListStatus(Anime anime, String listName) async {
    setState(() => _isUpdating = true);

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adding to $listName...'),
            duration: const Duration(milliseconds: 500),
            backgroundColor: Colors.black,
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
  Future<void> _updateEpisodeProgress(Anime anime, int delta) async {
    try {
      if (delta > 0) {
        _confettiController.play();
      }

      await context.read<AnimeStore>().updateProgress(anime.id, delta);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress saved!'),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.black,
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

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              FutureBuilder<Anime?>(
                future: _fullDetailsFuture,
                builder: (context, snapshot) {
                  final anime = snapshot.data ?? widget.anime;
                  final shadowColor = ColorParser.parseAnimeColor(anime.color);

                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight:
                            300, // Increased height for the covering effect
                        pinned: true,
                        stretch: true,
                        backgroundColor: Colors.black,
                        leading: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                          ),
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
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black,
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
                                          color: shadowColor,
                                          offset: const Offset(8, 8),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: ExpressiveImage(
                                      imageUrl: anime.coverImage,
                                      fit: BoxFit.cover,
                                      skeletonColor: anime.parsedColor,
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
                          decoration: const BoxDecoration(
                            color: Colors.white,
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
                                                    fontWeight: FontWeight.bold,
                                                    height: 0.9,
                                                    color: Colors.black,
                                                  ),
                                                ).animate().fadeIn().slideY(
                                                  begin: 0.2,
                                                  end: 0,
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
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: shadowColor,
                                                    offset: const Offset(4, 4),
                                                    blurRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  const OutlinedStar(size: 18),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${anime.averageScore}%',
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ).animate().scale(delay: 200.ms),
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
                                      ).animate().fadeIn(delay: 300.ms),
                                      const SizedBox(height: 24),
                                      // Action Button
                                      SizedBox(
                                        width: double.infinity,
                                        child:
                                            ElevatedButton.icon(
                                              onPressed: _isUpdating
                                                  ? null
                                                  : () =>
                                                        _showListSelectionDialog(
                                                          anime,
                                                          currentListName,
                                                        ),
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
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                elevation: 0,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.zero,
                                                      side: BorderSide(
                                                        color: Colors.black,
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
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: shadowColor,
                                                offset: const Offset(6, 6),
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
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$currentEpisode / ${anime.episodes}',
                                                    style:
                                                        GoogleFonts.robotoMono(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
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
                                                    color: Colors.black,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      color: Colors.white,
                                                    ),
                                                    FractionallySizedBox(
                                                      widthFactor:
                                                          anime.episodes! > 0
                                                          ? currentEpisode /
                                                                anime.episodes!
                                                          : 0,
                                                      child: Container(
                                                        color: shadowColor,
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
                                                          : () =>
                                                                _updateEpisodeProgress(
                                                                  anime,
                                                                  -1,
                                                                ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                        foregroundColor:
                                                            Colors.black,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 12,
                                                            ),
                                                        elevation: 0,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero,
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .black,
                                                                width: 2,
                                                              ),
                                                            ),
                                                        disabledBackgroundColor:
                                                            Colors.grey[300],
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
                                                          : () =>
                                                                _updateEpisodeProgress(
                                                                  anime,
                                                                  1,
                                                                ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.black,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 12,
                                                            ),
                                                        elevation: 0,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero,
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .black,
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
                                          color: Colors.black,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: Colors.black,
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
                                                color: Colors.black87,
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
                                        color: Colors.black,
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
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black,
                                                    offset: Offset(4, 4),
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
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              character.role.toUpperCase(),
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
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
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 220,
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
                                        return GestureDetector(
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
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: 100,
                                                    height: 140,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.zero,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 3,
                                                      ),
                                                      boxShadow: const [
                                                        BoxShadow(
                                                          color: Colors.black,
                                                          offset: Offset(4, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ExpressiveImage(
                                                      imageUrl:
                                                          relAnime.coverImage ??
                                                          '',
                                                      fit: BoxFit.cover,
                                                      skeletonColor:
                                                          relAnime.parsedColor,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    left: 0,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 3,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .zero, // Sharp
                                                      ),
                                                      child: Text(
                                                        relation.relationType
                                                            .replaceAll(
                                                              '_',
                                                              ' ',
                                                            )
                                                            .toUpperCase(),
                                                        style: GoogleFonts.teko(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  relAnime.title.toUpperCase(),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.teko(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    height: 1.1,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
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
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.zero,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 3,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black,
                                                    offset: Offset(4, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ExpressiveImage(
                                                imageUrl: rec.coverImage ?? '',
                                                fit: BoxFit.cover,
                                                skeletonColor: rec.parsedColor,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              width: 100,
                                              child: Text(
                                                rec.title.toUpperCase(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.teko(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  height: 1.1,
                                                ),
                                              ),
                                            ),
                                          ],
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
