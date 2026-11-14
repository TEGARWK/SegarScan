/// Recognized fruits and qualities in SegarScan
class FruitConstants {
  FruitConstants._();

  static const List<String> supportedFruits = [
    'apel',
    'jeruk',
    'pisang',
    'mangga',
    'tomat',
  ];

  static String formatFruitName(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  static String getQualityLabel(String quality) {
    switch (quality.toLowerCase()) {
      case 'bagus':
        return 'Bagus (Segar)';
      case 'cukup':
        return 'Cukup (Konsumsi Segera)';
      case 'busuk':
        return 'Busuk (Tidak Layak)';
      default:
        return quality;
    }
  }

  static String getQualityRecommendation(String quality) {
    switch (quality.toLowerCase()) {
      case 'bagus':
        return 'Buah dalam kondisi segar prima. Sangat layak untuk dijual atau dikonsumsi langsung.';
      case 'cukup':
        return 'Kondisi buah mendekati batas kematangan. Sebaiknya segera dikonsumsi atau diolah.';
      case 'busuk':
        return 'Buah telah mengalami pembusukan atau cacat parah. Pisahkan dari buah lain untuk mencegah kontaminasi.';
      default:
        return 'Hasil sortir memerlukan verifikasi lebih lanjut.';
    }
  }
}
