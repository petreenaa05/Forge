import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final bool showNumber;

  const RatingWidget({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 16,
    this.showNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(starCount, (index) {
          final filled = index < rating.floor();
          final halfFilled = !filled && index < rating;
          return Icon(
            halfFilled
                ? Icons.star_half_rounded
                : filled
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: filled || halfFilled
                ? const Color(0xFFFBBF24)
                : const Color(0xFFD1D5DB),
          );
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ],
    );
  }
}
