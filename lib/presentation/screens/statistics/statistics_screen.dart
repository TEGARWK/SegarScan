import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/fruit_constants.dart';
import '../../../providers/statistics_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  final Function(int) onNavigateToScan;

  const StatisticsScreen({super.key, required this.onNavigateToScan});

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

  String _getBusinessInsight(double goodPercent, int total) {
    if (total == 0) return 'Belum ada data untuk menghasilkan analisis.';
    if (goodPercent >= 75) {
      return 'Kualitas stok buah sangat prima! ${goodPercent.toStringAsFixed(0)}% buah berkondisi segar layak jual premium.';
    } else if (goodPercent >= 50) {
      return 'Kualitas buah cukup baik. Perhatikan buah kategori cukup matang agar segera terjual atau dikonsumsi.';
    } else {
      return 'Tingkat pembusukan terpantau cukup tinggi. Disarankan evaluasi suhu penyimpanan dan waktu distribusi buah.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      body: Column(
        children: [
          // 1. Header Hijau Segar Bersih Selaras Beranda & Layar Lainnya (Tanpa Pill)
          _buildHeader(context),

          // 2. Konten Statistik
          Expanded(
            child: statsAsync.when(
              data: (data) {
                if (data.totalScans == 0) {
                  return _buildEmptyState();
                }

                final goodCount = data.qualityCounts['bagus'] ?? 0;
                final fairCount = data.qualityCounts['cukup'] ?? 0;
                final badCount = data.qualityCounts['busuk'] ?? 0;

                // Buah paling banyak disortir
                String topFruit = '-';
                int topFruitCount = 0;
                if (data.fruitCounts.isNotEmpty) {
                  final topEntry = data.fruitCounts.entries.reduce(
                    (a, b) => a.value > b.value ? a : b,
                  );
                  topFruit = FruitConstants.formatFruitName(topEntry.key);
                  topFruitCount = topEntry.value;
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    // Top 4 Metrics Grid
                    _buildMetricsGrid(data, goodCount, topFruit, topFruitCount),

                    const SizedBox(height: 18),

                    // Donut Chart Komposisi Mutu
                    _buildQualityCompositionCard(data, goodCount, fairCount, badCount),

                    const SizedBox(height: 18),

                    // Insight Cerdas Pak Segar
                    _buildSmartInsightCard(data.goodPercentage, data.totalScans),

                    const SizedBox(height: 18),

                    // Distribusi Jenis Buah (Ranking List)
                    _buildFruitBreakdownCard(data),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                  strokeWidth: 3.5,
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Gagal memuat statistik: $err',
                    style: const TextStyle(color: AppColors.qualityBad),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Header Bersih tanpa pill/badge berlebih
  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF388E3C), // Hijau Segar identik Beranda
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // Bola-bola dekoratif halus khas SegarScan
          Positioned(
            top: topPadding - 10,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 20,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Judul & Subjudul
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistik & Analisis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ringkasan performa & distribusi mutu sortir buah',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Grid 4 Metrik Utama
  Widget _buildMetricsGrid(
    StatisticsData data,
    int goodCount,
    String topFruit,
    int topFruitCount,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Total Buah',
                value: '${data.totalScans}',
                unit: 'buah',
                icon: Icons.inventory_2_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Rasio Segar Prima',
                value: '${data.goodPercentage.toStringAsFixed(1)}%',
                unit: 'kualitas bagus',
                icon: Icons.thumb_up_alt_rounded,
                iconColor: const Color(0xFF1B5E20),
                iconBg: const Color(0xFFDCEFDC),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Buah Terbanyak',
                value: topFruit,
                unit: '$topFruitCount kali scan',
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFF57F17),
                iconBg: const Color(0xFFFFF9C4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Total Layak Jual',
                value: '${goodCount + (data.qualityCounts['cukup'] ?? 0)}',
                unit: 'bagus & cukup',
                icon: Icons.verified_rounded,
                iconColor: const Color(0xFF0288D1),
                iconBg: const Color(0xFFE1F5FE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EFE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Card Donut Chart Komposisi Mutu Buah
  Widget _buildQualityCompositionCard(
    StatisticsData data,
    int goodCount,
    int fairCount,
    int badCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EFE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Komposisi Mutu Buah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Perbandingan status mutu dari total scan',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${data.totalScans} Scan',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Donut Chart dengan Persentase di Tengah
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 48,
                    startDegreeOffset: -90,
                    sections: [
                      if (goodCount > 0)
                        PieChartSectionData(
                          color: AppColors.qualityGood,
                          value: goodCount.toDouble(),
                          title: '',
                          radius: 36,
                        ),
                      if (fairCount > 0)
                        PieChartSectionData(
                          color: AppColors.qualityFair,
                          value: fairCount.toDouble(),
                          title: '',
                          radius: 36,
                        ),
                      if (badCount > 0)
                        PieChartSectionData(
                          color: AppColors.qualityBad,
                          value: badCount.toDouble(),
                          title: '',
                          radius: 36,
                        ),
                    ],
                  ),
                ),
                // Text di Tengah Donut
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${data.goodPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'Prima',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3 Legend Badges Terstruktur
          Row(
            children: [
              _buildLegendCard(
                label: 'Bagus',
                count: goodCount,
                percent: (goodCount / data.totalScans * 100),
                color: AppColors.qualityGood,
                bgColor: const Color(0xFFE8F5E9),
              ),
              const SizedBox(width: 8),
              _buildLegendCard(
                label: 'Cukup',
                count: fairCount,
                percent: (fairCount / data.totalScans * 100),
                color: AppColors.qualityFair,
                bgColor: const Color(0xFFFFF8E1),
              ),
              const SizedBox(width: 8),
              _buildLegendCard(
                label: 'Busuk',
                count: badCount,
                percent: (badCount / data.totalScans * 100),
                color: AppColors.qualityBad,
                bgColor: const Color(0xFFFFEBEE),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard({
    required String label,
    required int count,
    required double percent,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$count buah',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 10.5,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card Insight Cerdas Pak Segar
  Widget _buildSmartInsightCard(double goodPercentage, int total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8F2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE8DC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF388E3C),
            ),
            child: const Center(
              child: Text('👨‍🌾', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Evaluasi Mutu Pak Segar',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '• Analisis AI',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _getBusinessInsight(goodPercentage, total),
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
    );
  }

  /// Card Distribusi Berdasarkan Jenis Buah (Ranking Bar List)
  Widget _buildFruitBreakdownCard(StatisticsData data) {
    final sortedEntries = data.fruitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EFE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribusi Jenis Buah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Frekuensi buah yang paling sering disortir',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),

          ...sortedEntries.map((entry) {
            final percentage = (entry.value / data.totalScans);
            final emoji = _getFruitEmoji(entry.key);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            FruitConstants.formatFruitName(entry.key),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value} scan (${(percentage * 100).toInt()}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFEDF2ED),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF388E3C),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Empty State saat belum ada pemindaian
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.pie_chart_outline_rounded,
                  color: Color(0xFF388E3C),
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Data Statistik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lakukan pemindaian buah untuk melihat grafik perbandingan mutu dan distribusinya di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                foregroundColor: Colors.white,
                elevation: 1,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => onNavigateToScan(1),
              icon: const Icon(Icons.camera_alt_rounded, size: 19),
              label: const Text(
                'Mulai Pindai Buah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
