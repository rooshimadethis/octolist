import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/anime_store.dart';
import '../theme/expressive_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class VibeSlider extends StatelessWidget {
  const VibeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimeStore>(
      builder: (context, store, child) {
        final vibeScore = store.vibeScore;
        final primaryText = ExpressiveTheme.getPrimaryText(vibeScore);
        final shadowColor = ExpressiveTheme.getShadowColor(vibeScore);

        return Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(color: primaryText, width: 2),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DEBUG VIBE: ${(vibeScore * 100).toInt()}%',
                  style: GoogleFonts.teko(
                    color: primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: primaryText,
                      inactiveTrackColor: primaryText.withValues(alpha: 0.2),
                      thumbColor: primaryText,
                      overlayColor: primaryText.withValues(alpha: 0.1),
                    ),
                    child: Slider(
                      value: vibeScore,
                      onChanged: (value) {
                        store.vibeScore = value;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
