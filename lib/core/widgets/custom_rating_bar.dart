import 'package:flutter/material.dart';

class CustomRatingBar extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const CustomRatingBar({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.size = 15,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return Icon(
          Icons.star,
          size: size,
          color:
              index < rating.floor()
                  ? activeColor
                  : inactiveColor.withOpacity(0.3),
        );
      }),
    );
  }
}
