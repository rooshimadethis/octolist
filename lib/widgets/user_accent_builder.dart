import 'package:flutter/material.dart';
import '../services/image_color_service.dart';
import '../theme/expressive_theme.dart';

/// A builder widget that provides a user-specific accent color based on their avatar.
/// Falls back to AniList profileColor and then back to the theme's heart color.
class UserAccentBuilder extends StatefulWidget {
  final String avatarUrl;
  final String? profileColorName;
  final double vibeScore;
  final Widget Function(BuildContext context, Color color) builder;

  const UserAccentBuilder({
    super.key,
    required this.avatarUrl,
    this.profileColorName,
    this.vibeScore = 0.0,
    required this.builder,
  });

  @override
  State<UserAccentBuilder> createState() => _UserAccentBuilderState();
}

class _UserAccentBuilderState extends State<UserAccentBuilder> {
  Color? _extractedColor;

  @override
  void initState() {
    super.initState();
    _loadColor();
  }

  @override
  void didUpdateWidget(UserAccentBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl) {
      _loadColor();
    }
  }

  Future<void> _loadColor() async {
    if (widget.avatarUrl.isEmpty) {
      if (mounted) setState(() => _extractedColor = null);
      return;
    }

    final cached = ImageColorService.getCachedColor(widget.avatarUrl);
    if (cached != null) {
      if (mounted) setState(() => _extractedColor = cached);
      return;
    }

    final color = await ImageColorService.extractDominantColor(
      widget.avatarUrl,
    );
    if (mounted) {
      setState(() => _extractedColor = color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileColor = ExpressiveTheme.parseAniListColor(
      widget.profileColorName,
    );

    // Resolution order: Extracted > Profile > Theme Default
    final color =
        _extractedColor ??
        profileColor ??
        ExpressiveTheme.getHeartColor(widget.vibeScore);

    return widget.builder(context, color);
  }
}
