import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/fruit_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/fruit_quality.dart';
import '../../../../data/models/scan_history_item.dart';
import '../../../../providers/history_provider.dart';
import '../../../widgets/pak_segar_widget.dart';
import '../../../widgets/quality_badge.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final ScanHistoryItem item;

  const HistoryDetailScreen({super.key, required this.item});

  String _getFruitEmoji(String fruit) {
    switch (fruit.toLowerCase()) {
      case 'apel':
        return '🍎';
      case 'jeruk':
        return '🍊';
      case 'pisang':
        return '🍌';
      case 'mangga':
        return '🥭';
      case 'tomat':
        return '🍅';
      default:
        return '🥑';
    }
  }

  PakSegarPose _getPakSegarPose(FruitQuality quality) {
    switch (quality) {
      case FruitQuality.bagus:
        return PakSegarPose.happy;
      case FruitQuality.cukup:
        return PakSegarPose.thinking;
      case FruitQuality.busuk:
        return PakSegarPose.worried;
    }
  }

  PakSegarQuality _getPakSegarQuality(FruitQuality quality) {
    switch (quality) {
      case FruitQuality.bagus:
        return PakSegarQuality.bagus;
      case FruitQuality.cukup:
        return PakSegarQuality.cukup;
      case FruitQuality.busuk:
        return PakSegarQuality.busuk;
    }
  }

  String _getPakSegarAdvice(FruitQuality quality, String fruit) {
    final fruitCapital = FruitConstants.formatFruitName(fruit);
    switch (quality) {
      case FruitQuality.bagus:
        return 'Buah $fruitCapital ini tercatat dalam kondisi mulus dan segar prima. Sangat layak jual dan konsumsi! 👍';
      case FruitQuality.cukup:
        return 'Kematangan sudah maksimal saat dipindai. Sebaiknya segera dikonsumsi atau diolah jadi jus! 🍹';
      case FruitQuality.busuk:
        return 'Tercatat adanya kerusakan atau pembusukan aktif pada buah $fruitCapital ini. Pisahkan dari buah segar lainnya! ⚠️';
    }
  }

  Map<String, String> _getActionGuidelines(FruitQuality quality) {
    switch (quality) {
      case FruitQuality.bagus:
        return {
          'temp': '4°C – 10°C (Kulkas / Ruang Sejuk)',
          'shelfLife': '5 – 7 Hari ke depan',
          'action': 'Siap dipajang atau dikonsumsi langsung',
        };
      case FruitQuality.cukup:
        return {
          'temp': '15°C – 20°C (Hindari sinar matahari)',
          'shelfLife': '1 – 2 Hari (Segera konsumsi)',
          'action': 'Cuci bersih, konsumsi cepat / olah jadi jus',
        };
      case FruitQuality.busuk:
        return {
          'temp': 'Segera buang dari ruang penyimpanan',
          'shelfLife': '0 Hari (Tidak layak konsumsi)',
          'action': 'Pisahkan segera & olah jadi pupuk kompos',
        };
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Hapus Catatan Ini?'),
        content: Text(
          'Catatan hasil sortir untuk ${FruitConstants.formatFruitName(item.fruitName)} akan dihapus dari riwayat.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.qualityBad,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (item.id != null) {
                ref.read(historyProvider.notifier).deleteItem(item.id!);
              }
              Navigator.of(ctx).pop(); // Tutup dialog
              Navigator.of(context).pop(); // Kembali ke list riwayat
            },
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = File(item.imagePath);
    final dateStr = AppDateFormatter.formatDateTime(item.createdAt);
    final fruitEmoji = _getFruitEmoji(item.fruitName);
    final confPercent = (item.confidence * 100).toInt();
    final guidelines = _getActionGuidelines(item.quality);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8ECE8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Detail Riwayat',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: InkWell(
                onTap: () => _confirmDelete(context, ref),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8ECE8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 1. Preview Foto Buah dengan Badges
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 11,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    file.existsSync()
                        ? Image.file(file, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFE8F5E9),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Badge Atas Kiri: Sumber Inferensi
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.memory_rounded, color: Color(0xFF81C784), size: 14),
                            const SizedBox(width: 5),
                            Text(
                              'Inferensi: ${item.source.toUpperCase()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Badge Bawah Kanan: QualityBadge
                    Positioned(
                      bottom: 14,
                      right: 14,
                      child: QualityBadge(quality: item.quality, isLarge: false),
                    ),
                    // Badge Bawah Kiri: Emoji Buah & Tanggal
                    Positioned(
                      bottom: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(fruitEmoji, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(
                              FruitConstants.formatFruitName(item.fruitName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 2. Main Result Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8EFE8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0EEDE)),
                      ),
                      child: Center(
                        child: Text(fruitEmoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FruitConstants.formatFruitName(item.fruitName),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kategori: ${FruitConstants.getQualityLabel(item.quality.name)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: item.quality.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Waktu Scan: $dateStr',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    QualityBadge(quality: item.quality, isLarge: true),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(height: 1, color: Color(0xFFF0F4F0)),
                const SizedBox(height: 16),

                // Keyakinan Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tingkat Keyakinan AI',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$confPercent%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: item.quality.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: item.confidence.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEDF2ED),
                    valueColor: AlwaysStoppedAnimation<Color>(item.quality.color),
                  ),
                ),

                const SizedBox(height: 20),

                // Distribusi Probabilitas 3 Kelas
                const Text(
                  'Distribusi Probabilitas Kelas:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildModernProbCard(
                      label: 'Bagus',
                      value: item.probGood,
                      color: AppColors.qualityGood,
                      bgColor: const Color(0xFFE8F5E9),
                      isSelected: item.quality == FruitQuality.bagus,
                    ),
                    const SizedBox(width: 8),
                    _buildModernProbCard(
                      label: 'Cukup',
                      value: item.probFair,
                      color: AppColors.qualityFair,
                      bgColor: const Color(0xFFFFF8E1),
                      isSelected: item.quality == FruitQuality.cukup,
                    ),
                    const SizedBox(width: 8),
                    _buildModernProbCard(
                      label: 'Busuk',
                      value: item.probBad,
                      color: AppColors.qualityBad,
                      bgColor: const Color(0xFFFFEBEE),
                      isSelected: item.quality == FruitQuality.busuk,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Catatan Maskot Pak Segar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F8F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDCE8DC)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Karakter Asli Maskot Pak Segar Sesuai Hasil Sortir
                Container(
                  width: 72,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PakSegarWidget(
                      width: 72,
                      height: 84,
                      pose: _getPakSegarPose(item.quality),
                      fixedQuality: _getPakSegarQuality(item.quality),
                      fruitType: item.fruitName,
                      interactive: true,
                      showScannerBeam: false,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan Pak Segar',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPakSegarAdvice(item.quality, item.fruitName),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Rekomendasi Penanganan
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE8EFE8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.fact_check_outlined, color: Color(0xFF388E3C), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Rekomendasi Penanganan',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildGuidelineRow(
                  icon: Icons.thermostat_outlined,
                  title: 'Suhu Penyimpanan',
                  desc: guidelines['temp']!,
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1976D2),
                ),
                const SizedBox(height: 12),
                _buildGuidelineRow(
                  icon: Icons.timer_outlined,
                  title: 'Estimasi Daya Simpan',
                  desc: guidelines['shelfLife']!,
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFF57C00),
                ),
                const SizedBox(height: 12),
                _buildGuidelineRow(
                  icon: Icons.tips_and_updates_outlined,
                  title: 'Tindakan Direkomendasikan',
                  desc: guidelines['action']!,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF388E3C),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildModernProbCard({
    required String label,
    required double value,
    required Color color,
    required Color bgColor,
    required bool isSelected,
  }) {
    final percent = (value * 100).toInt();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : const Color(0xFFF9FAF9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : const Color(0xFFE8ECE8),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: const Color(0xFFE0E5E0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineRow({
    required IconData icon,
    required String title,
    required String desc,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
