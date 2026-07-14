import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        final star = Icon(
          filled ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
        if (onChanged == null) return star;
        return GestureDetector(
          onTap: () => onChanged!(i + 1),
          child: star,
        );
      }),
    );
  }
}
