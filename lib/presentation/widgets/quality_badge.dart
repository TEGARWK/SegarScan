import 'package:flutter/material.dart';
import '../../data/models/fruit_quality.dart';

class QualityBadge extends StatelessWidget {
  final FruitQuality quality;
  final bool isLarge;

  const QualityBadge({
    super.key,
    required this.quality,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 10,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: quality.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: quality.color.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            quality.icon,
            size: isLarge ? 20 : 15,
            color: quality.color,
          ),
          const SizedBox(width: 6),
          Text(
            quality.label,
            style: TextStyle(
              color: quality.color,
              fontSize: isLarge ? 15 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
