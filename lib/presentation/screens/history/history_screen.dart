import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/fruit_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/statistics_provider.dart';
import '../../widgets/quality_badge.dart';
import 'detail/history_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  final Function(int) onNavigateToScan;

  const HistoryScreen({super.key, required this.onNavigateToScan});

  void _showClearConfirmDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.qualityBad, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Hapus Semua Riwayat?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Seluruh data hasil sortir buah yang tersimpan di perangkat akan dihapus secara permanen.',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.qualityBad,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Semua riwayat sortir telah dihapus'),
                  backgroundColor: AppColors.qualityBad,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Hapus Semua', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final statsAsync = ref.watch(statisticsProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      body: Column(
        children: [
          // 1. Header Hijau Segar Selaras Beranda & ScanScreen
          _buildHeader(context, ref, historyState.items.isNotEmpty, statsAsync),

          // 2. Filter Kualitas Modern (Semua, Bagus, Cukup, Busuk)
          _buildFilterBar(historyState, notifier),

          // 3. Konten Daftar Riwayat atau Empty State
          Expanded(
            child: historyState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                      strokeWidth: 3.5,
                    ),
                  )
                : historyState.items.isEmpty
                    ? _buildEmptyState(historyState.selectedQualityFilter, notifier)
                    : _buildHistoryListView(context, historyState, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    bool hasItems,
    AsyncValue<StatisticsData> statsAsync,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;
    final stats = statsAsync.value;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF388E3C), // Hijau Segar khas SegarScan
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Konten Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Tombol Hapus Semua Sejajar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Riwayat Sortir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Catatan hasil pemeriksaan mutu buah Anda',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (hasItems)
                        IconButton(
                          onPressed: () => _showClearConfirmDialog(context, ref),
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 26),
                          tooltip: 'Hapus Semua Riwayat',
                        ),
                    ],
                  ),

                  // Kapsul Ringkasan Cepat (Mini Summary Stats)
                  if (stats != null && stats.totalScans > 0) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHeaderStatItem('Total', '${stats.totalScans}'),
                          _buildHeaderDivider(),
                          _buildHeaderStatItem('Bagus', '${stats.qualityCounts['bagus'] ?? 0}', dotColor: const Color(0xFF81C784)),
                          _buildHeaderDivider(),
                          _buildHeaderStatItem('Cukup', '${stats.qualityCounts['cukup'] ?? 0}', dotColor: const Color(0xFFFFD54F)),
                          _buildHeaderDivider(),
                          _buildHeaderStatItem('Busuk', '${stats.qualityCounts['busuk'] ?? 0}', dotColor: const Color(0xFFE57373)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatItem(String label, String value, {Color? dotColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dotColor != null) ...[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 5),
        ],
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderDivider() {
    return Container(
      width: 1,
      height: 14,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }

  Widget _buildFilterBar(HistoryState state, HistoryNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Semua',
            isSelected: state.selectedQualityFilter == null,
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.filterByQuality(null);
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Bagus',
            isSelected: state.selectedQualityFilter == 'bagus',
            color: AppColors.qualityGood,
            bgColor: const Color(0xFFE8F5E9),
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.filterByQuality('bagus');
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Cukup',
            isSelected: state.selectedQualityFilter == 'cukup',
            color: AppColors.qualityFair,
            bgColor: const Color(0xFFFFF8E1),
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.filterByQuality('cukup');
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Busuk',
            isSelected: state.selectedQualityFilter == 'busuk',
            color: AppColors.qualityBad,
            bgColor: const Color(0xFFFFEBEE),
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.filterByQuality('busuk');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = const Color(0xFF388E3C),
    Color bgColor = const Color(0xFFE8F5E9),
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? bgColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE0E6E0),
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryListView(
    BuildContext context,
    HistoryState state,
    HistoryNotifier notifier,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        final file = File(item.imagePath);
        final dateStr = AppDateFormatter.formatDateTime(item.createdAt);
        final fruitEmoji = _getFruitEmoji(item.fruitName);
        final confPercent = (item.confidence * 100).toInt();

        return Dismissible(
          key: ValueKey(item.id ?? index),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 22),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.qualityBad,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Hapus',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
              ],
            ),
          ),
          onDismissed: (_) {
            if (item.id != null) {
              notifier.deleteItem(item.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Riwayat ${item.fruitName} berhasil dihapus'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8EFE8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryDetailScreen(item: item),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Thumbnail Foto Buah dengan Overlay Emoji
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: file.existsSync()
                                ? Image.file(
                                    file,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 72,
                                    height: 72,
                                    color: const Color(0xFFF1F8F1),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: AppColors.primaryGreen,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Text(fruitEmoji, style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Informasi Buah & Keyakinan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FruitConstants.formatFruitName(item.fruitName),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  'Akurasi: $confPercent%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item.quality.color,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    dateStr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Mini Linear Meter Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: item.confidence.clamp(0.0, 1.0),
                                minHeight: 4,
                                backgroundColor: const Color(0xFFEDF2ED),
                                valueColor: AlwaysStoppedAnimation<Color>(item.quality.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Badge Kualitas & Icon Chevron
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          QualityBadge(quality: item.quality, isLarge: false),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Color(0xFFB0BEC5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String? selectedFilter, HistoryNotifier notifier) {
    final isFiltered = selectedFilter != null;

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
                  Icons.history_toggle_off_rounded,
                  color: Color(0xFF388E3C),
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'Tidak Ada Hasil Filter' : 'Belum Ada Riwayat Sortir',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Tidak ditemukan catatan sortir untuk kategori "${selectedFilter.toUpperCase()}".'
                  : 'Mulai pindai buah dari kamera atau galeri untuk melihat catatan riwayat di sini.',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
              onPressed: () {
                if (isFiltered) {
                  notifier.filterByQuality(null);
                } else {
                  onNavigateToScan(1);
                }
              },
              icon: Icon(
                isFiltered ? Icons.refresh_rounded : Icons.camera_alt_rounded,
                size: 19,
              ),
              label: Text(
                isFiltered ? 'Tampilkan Semua' : 'Mulai Pindai Buah',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
