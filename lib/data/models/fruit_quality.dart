import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum FruitQuality {
  bagus,
  cukup,
  busuk;

  static FruitQuality fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bagus':
      case 'good':
        return FruitQuality.bagus;
      case 'cukup':
      case 'fair':
        return FruitQuality.cukup;
      case 'busuk':
      case 'bad':
      case 'rotten':
        return FruitQuality.busuk;
      default:
        return FruitQuality.cukup;
    }
  }

  String get label {
    switch (this) {
      case FruitQuality.bagus:
        return 'Bagus';
      case FruitQuality.cukup:
        return 'Cukup';
      case FruitQuality.busuk:
        return 'Busuk';
    }
  }

  Color get color {
    switch (this) {
      case FruitQuality.bagus:
        return AppColors.qualityGood;
      case FruitQuality.cukup:
        return AppColors.qualityFair;
      case FruitQuality.busuk:
        return AppColors.qualityBad;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case FruitQuality.bagus:
        return AppColors.qualityGoodBg;
      case FruitQuality.cukup:
        return AppColors.qualityFairBg;
      case FruitQuality.busuk:
        return AppColors.qualityBadBg;
    }
  }

  IconData get icon {
    switch (this) {
      case FruitQuality.bagus:
        return Icons.check_circle_rounded;
      case FruitQuality.cukup:
        return Icons.info_rounded;
      case FruitQuality.busuk:
        return Icons.cancel_rounded;
    }
  }
}
