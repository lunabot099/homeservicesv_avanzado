/// rating_stars.dart
/// Widget de estrellas de calificación — modo lectura y modo selección.
library;

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Estrellas de solo lectura.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final int maxStars;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        final filled = i < rating.floor();
        final half = !filled && (rating - i) >= 0.5;

        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
          color: AppColors.warning,
        );
      }),
    );
  }
}

/// Estrellas interactivas (modo selección).
class RatingStarsSelector extends StatelessWidget {
  final double rating;
  final void Function(double) onRatingChanged;
  final double size;
  final int maxStars;

  const RatingStarsSelector({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 40,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        return GestureDetector(
          onTap: () => onRatingChanged((i + 1).toDouble()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: AppColors.warning,
            ),
          ),
        );
      }),
    );
  }
}
