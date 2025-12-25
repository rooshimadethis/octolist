enum VibeLevel { radiant, neutral, grim, abyssal }

/// Determines the VibeLevel based on a normalized score (0.0 - 1.0).
VibeLevel getVibeLevel(double score) {
  if (score < 0.25) return VibeLevel.radiant;
  if (score < 0.50) return VibeLevel.neutral;
  if (score < 0.75) return VibeLevel.grim;
  return VibeLevel.abyssal;
}
