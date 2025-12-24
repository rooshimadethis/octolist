import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/user_profile.dart';
import '../theme/expressive_theme.dart';
import 'expressive_image.dart';
import 'vibe_slider.dart';

/// Shows a manga-style user profile dialog with stats and status counts
class UserProfileDialog extends StatelessWidget {
  final UserProfile user;

  const UserProfileDialog({super.key, required this.user});

  /// Shows the user profile dialog
  static void show(BuildContext context, UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: ExpressiveTheme.spacingXL,
        ),
        child: UserProfileDialog(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ExpressiveTheme.spacingXL),
      decoration: BoxDecoration(
        color: ExpressiveTheme.surfaceWhite,
        border: Border.all(
          color: ExpressiveTheme.primaryBlack,
          width: ExpressiveTheme.borderWidthThick,
        ),
        boxShadow: ExpressiveTheme.hardShadows(
          offset: ExpressiveTheme.shadowOffsetXXLarge,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ExpressiveTheme.primaryBlack,
                    width: ExpressiveTheme.borderWidthMedium,
                  ),
                  boxShadow: ExpressiveTheme.hardShadows(
                    offset: ExpressiveTheme.shadowOffsetMedium,
                  ),
                ),
                child: ExpressiveImage(
                  imageUrl: user.avatarLarge,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: ExpressiveTheme.spacingXL),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.toUpperCase(),
                      style: GoogleFonts.teko(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: ExpressiveTheme.spacingXS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ExpressiveTheme.spacingS,
                        vertical: 2,
                      ),
                      color: ExpressiveTheme.mangaRed,
                      child: Text(
                        'PREMIUM OTAKU',
                        style: GoogleFonts.teko(
                          color: ExpressiveTheme.surfaceWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: ExpressiveTheme.primaryBlack,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: ExpressiveTheme.spacingXXL),
          Text(
            'ANIME STATISTICS',
            style: ExpressiveTheme.titleMedium().copyWith(
              fontStyle: FontStyle.italic,
              decoration: TextDecoration.underline,
              decorationThickness: 2,
            ),
          ),
          const SizedBox(height: ExpressiveTheme.spacingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'WATCHED',
                (user.stats?.episodesWatched ?? 0).toString(),
                PhosphorIcons.play(),
              ),
              _buildStatItem(
                'DAYS',
                ((user.stats?.minutesWatched ?? 0) / 1440).toStringAsFixed(1),
                PhosphorIcons.clock(),
              ),
              _buildStatItem(
                'MEAN SCORE',
                (user.stats?.meanScore ?? 0).toString(),
                PhosphorIcons.star(),
              ),
            ],
          ),
          const SizedBox(height: ExpressiveTheme.spacingXL),
          Text(
            'LIST STATUS',
            style: ExpressiveTheme.titleMedium().copyWith(
              fontStyle: FontStyle.italic,
              decoration: TextDecoration.underline,
              decorationThickness: 2,
            ),
          ),
          const SizedBox(height: ExpressiveTheme.spacingM),
          Wrap(
            spacing: ExpressiveTheme.spacingS,
            runSpacing: ExpressiveTheme.spacingS,
            children: (user.stats?.statuses ?? []).map((s) {
              return _buildStatusChip(s.status, s.count);
            }).toList(),
          ),
          const SizedBox(height: ExpressiveTheme.spacingXXL),
          const SizedBox(width: double.infinity, child: VibeSlider()),
          const SizedBox(height: ExpressiveTheme.spacingL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: ExpressiveTheme.primaryBlack,
                foregroundColor: ExpressiveTheme.surfaceWhite,
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(
                  vertical: ExpressiveTheme.spacingL,
                ),
                elevation: 0,
              ),
              child: Text(
                'CLOSE PROFILE',
                style: ExpressiveTheme.titleSmall(
                  color: ExpressiveTheme.surfaceWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, PhosphorIconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: ExpressiveTheme.primaryBlack),
        const SizedBox(height: ExpressiveTheme.spacingXS),
        Text(
          value,
          style: GoogleFonts.teko(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.teko(
            fontSize: 14,
            color: Colors.grey[700],
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ExpressiveTheme.spacingM,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: ExpressiveTheme.surfaceWhite,
        border: Border.all(
          color: ExpressiveTheme.primaryBlack,
          width: ExpressiveTheme.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            style: GoogleFonts.teko(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ExpressiveTheme.primaryBlack,
            ),
          ),
          const SizedBox(width: ExpressiveTheme.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ExpressiveTheme.spacingXS,
            ),
            color: ExpressiveTheme.primaryBlack,
            child: Text(
              '$count',
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ExpressiveTheme.surfaceWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
