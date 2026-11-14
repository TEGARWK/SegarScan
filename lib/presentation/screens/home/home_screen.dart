import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/fruit_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/scan_state_provider.dart';
import '../../../providers/statistics_provider.dart';
import '../../widgets/pak_segar_loading_widget.dart';
import '../../widgets/pak_segar_widget.dart';
import '../../widgets/quality_badge.dart';
import '../../../data/models/fruit_quality.dart';
import '../result/result_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startScan(BuildContext context, ImageSource source) async {
    final notifier = ref.read(scanStateProvider.notifier);
    await notifier.pickAndClassify(source);

    if (context.mounted) {
      final state = ref.read(scanStateProvider);
      if (state.status == ScanStatus.success && state.result != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              prediction: state.result!,
              imageFile: state.selectedImage!,
            ),
          ),
        );
      } else if (state.status == ScanStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Terjadi kesalahan saat memproses gambar'),
            backgroundColor: AppColors.qualityBad,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showGuidanceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_rounded,
                    color: AppColors.primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Panduan Pemotretan AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Untuk mendapatkan hasil klasifikasi mutu buah dengan tingkat keyakinan (confidence) tertinggi:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildGuideItem(
              icon: Icons.wb_sunny_outlined,
              title: 'Pencahayaan Alami & Terang',
              desc: 'Hindari bayangan pekat pada permukaan buah agar tekstur dan warna terbaca akurat.',
            ),
            _buildGuideItem(
              icon: Icons.filter_center_focus_rounded,
              title: 'Satu Buah per Pengambilan',
              desc: 'Fokuskan kamera pada 1 buah di tengah frame tanpa objek lain di dekatnya.',
            ),
            _buildGuideItem(
              icon: Icons.crop_portrait_rounded,
              title: 'Latar Belakang Netral',
              desc: 'Gunakan alas meja polos (putih/kayu) atau telapak tangan bersih sebagai latar belakang.',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Saya Mengerti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statisticsProvider);
    final scanState = ref.watch(scanStateProvider);

    // Hitung progress scroll (0.0 di puncak, 1.0 saat di-scroll sejauh 85px)
    final scrollProgress = (_scrollOffset / 85.0).clamp(0.0, 1.0);

    // Transisi warna bertahap (lerp) dari Transparan (puncak) ke Putih Bersih (saat di-scroll)
    final appBarBg = Color.lerp(Colors.transparent, Colors.white, scrollProgress)!;
    final titleColor = Color.lerp(Colors.white, AppColors.textPrimary, scrollProgress)!;
    final subtitleColor = Color.lerp(Colors.white.withValues(alpha: 0.85), AppColors.textMuted, scrollProgress)!;

    final emblemBg = Color.lerp(Colors.white.withValues(alpha: 0.22), AppColors.primaryLight, scrollProgress)!;
    final emblemBorder = Color.lerp(Colors.white.withValues(alpha: 0.35), AppColors.primaryGreen.withValues(alpha: 0.25), scrollProgress)!;
    final emblemIconColor = Color.lerp(Colors.white, AppColors.primaryGreen, scrollProgress)!;

    // Action button colors
    final actionBtnBg = Color.lerp(Colors.white.withValues(alpha: 0.2), Colors.white, scrollProgress)!;
    final actionBtnBorder = Color.lerp(Colors.white.withValues(alpha: 0.35), const Color(0xFFEDF2EE), scrollProgress)!;
    final actionBtnIconColor = Color.lerp(Colors.white, AppColors.textPrimary, scrollProgress)!;
    final appBarElevation = scrollProgress > 0.8 ? (scrollProgress - 0.8) * 8.0 : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          elevation: appBarElevation,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          backgroundColor: appBarBg,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: scrollProgress > 0.5
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
          titleSpacing: 20,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: emblemBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: emblemBorder,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.energy_savings_leaf_rounded,
                  color: emblemIconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SegarScan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: -0.2,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    'Sortir Mutu Buah AI',
                    style: TextStyle(
                      fontSize: 11,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            _buildAppBarActionBtn(
              icon: Icons.tips_and_updates_outlined,
              tooltip: 'Panduan Pemotretan',
              onTap: () => _showGuidanceBottomSheet(context),
              bgColor: actionBtnBg,
              iconColor: actionBtnIconColor,
              border: Border.all(color: actionBtnBorder),
            ),
            const SizedBox(width: 8),
            _buildAppBarActionBtn(
              icon: Icons.settings_outlined,
              tooltip: 'Pengaturan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              bgColor: actionBtnBg,
              iconColor: actionBtnIconColor,
              border: Border.all(color: actionBtnBorder),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      body: scanState.status == ScanStatus.loading
          ? const SafeArea(
              child: PakSegarLoadingWidget(
                title: 'Menganalisis Kualitas Buah...',
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(statisticsProvider);
              },
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // 1. Unified Green Hero Container (Menyatu dari puncak layar & AppBar dengan aksen bola-bola)
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        color: Color(0xFF388E3C),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33388E3C),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Bola-bola Dekoratif Latar Belakang (Translucent Floating Bubbles — Bulat Utuh & Rapi)
                          // 1. Glow Lingkaran Lembut di Belakang Pak Segar (memudar lembut ke tepi, tidak tajam)
                          Positioned(
                            top: 85,
                            right: 8,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.16),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 2. Bola Ring Halus di Sela Atas (Antara Teks & Pak Segar)
                          Positioned(
                            top: 92,
                            right: 156,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          // 3. Bola Transparan Kecil di Kiri Atas
                          Positioned(
                            top: 96,
                            left: 20,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.14),
                              ),
                            ),
                          ),
                          // 4. Bola Sedang Halus di Kiri Tengah
                          Positioned(
                            top: 172,
                            left: 14,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          // 5. Bola Ring di Kanan Bawah (Dekat Keranjang Buah)
                          Positioned(
                            bottom: 56,
                            right: 12,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.07),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          // 6. Titik Kilau / Sparkle Kecil di Tengah
                          Positioned(
                            top: 154,
                            right: 144,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                          ),

                          // Konten Utama Hero
                          Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + kToolbarHeight + 4,
                              left: 20,
                              right: 20,
                              bottom: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row Konten Utama: Sapaan & Ajakan Aksi (Kiri) & Maskot Pak Segar (Kanan)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Kolom Teks Clean, Modern & Action-Oriented di Kiri
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Hai, Sobat Tani 👋',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: -0.1,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'Yuk, Periksa\nBuahmu!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              height: 1.15,
                                              letterSpacing: -0.4,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Foto atau unggah buah untuk deteksi kesegarannya.',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.9),
                                              fontSize: 12.5,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // Maskot Karakter "Pak Segar" (Besar, Gagah, Jelas & Proporsional)
                                    const PakSegarWidget(
                                      width: 154,
                                      height: 180,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Tombol Aksi Kamera & Galeri
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: AppColors.primaryDark,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 13),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: () => _startScan(context, ImageSource.camera),
                                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                        label: const Text('Buka Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.white, width: 1.5),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 13),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        onPressed: () => _startScan(context, ImageSource.gallery),
                                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                                        label: const Text('Dari Galeri', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 2. Konten Halaman Bawah (Ringkasan, Buah, Tips, Aktivitas)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Ringkasan Eksekutif
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ringkasan Sortir',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => widget.onTabChange(3), // Tab Statistik
                              child: const Text('Lihat Grafik', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        statsAsync.when(
                          data: (data) {
                            final good = data.qualityCounts['bagus'] ?? 0;
                            final fair = data.qualityCounts['cukup'] ?? 0;
                            final bad = data.qualityCounts['busuk'] ?? 0;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFEDF2EE)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Row 4 Kolom Metrik dengan Pembatas Halus
                                  Row(
                                    children: [
                                      _buildUnifiedStatCol(
                                        label: 'Total',
                                        value: '${data.totalScans}',
                                        icon: Icons.inventory_2_rounded,
                                        color: AppColors.primaryGreen,
                                        bgColor: AppColors.primaryLight,
                                      ),
                                      _buildVerticalDivider(),
                                      _buildUnifiedStatCol(
                                        label: 'Bagus',
                                        value: '$good',
                                        icon: Icons.check_circle_rounded,
                                        color: AppColors.qualityGood,
                                        bgColor: AppColors.qualityGoodBg,
                                      ),
                                      _buildVerticalDivider(),
                                      _buildUnifiedStatCol(
                                        label: 'Cukup',
                                        value: '$fair',
                                        icon: Icons.info_rounded,
                                        color: AppColors.qualityFair,
                                        bgColor: AppColors.qualityFairBg,
                                      ),
                                      _buildVerticalDivider(),
                                      _buildUnifiedStatCol(
                                        label: 'Busuk',
                                        value: '$bad',
                                        icon: Icons.cancel_rounded,
                                        color: AppColors.qualityBad,
                                        bgColor: AppColors.qualityBadBg,
                                      ),
                                    ],
                                  ),

                                  // Bagian Bawah: Rasio Layak Jual
                                  const SizedBox(height: 14),
                                  const Divider(height: 1, color: Color(0xFFF2F4F2)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.thumb_up_alt_rounded, color: AppColors.primaryGreen, size: 15),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Rasio Layak Konsumsi / Jual',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${data.goodPercentage.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: data.totalScans > 0 ? (data.goodPercentage / 100).clamp(0.0, 1.0) : 0.0,
                                      backgroundColor: const Color(0xFFF0F4F0),
                                      color: AppColors.primaryGreen,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(color: AppColors.primaryGreen),
                            ),
                          ),
                          error: (e, _) => Center(child: Text('Gagal memuat statistik: $e')),
                        ),

                        const SizedBox(height: 28),

                        // Section Buah yang Didukung (Modern Pastel Category Card)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFEDF2EE)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.category_rounded, size: 18, color: AppColors.primaryGreen),
                                      SizedBox(width: 8),
                                      Text(
                                        'Buah yang Didukung',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '5 Buah AI',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildFruitAvatarItem(
                                    context: context,
                                    emoji: '🍎',
                                    name: 'Apel',
                                    bgColor: const Color(0xFFFFEBEE),
                                    borderColor: const Color(0xFFFFCDD2),
                                    desc: 'Deteksi kematangan kulit, bercak memar, dan busuk pada apel.',
                                  ),
                                  _buildFruitAvatarItem(
                                    context: context,
                                    emoji: '🍊',
                                    name: 'Jeruk',
                                    bgColor: const Color(0xFFFFF3E0),
                                    borderColor: const Color(0xFFFFE0B2),
                                    desc: 'Deteksi kesegaran pori kulit, tingkat kekuningan, dan bintik busuk pada jeruk.',
                                  ),
                                  _buildFruitAvatarItem(
                                    context: context,
                                    emoji: '🍌',
                                    name: 'Pisang',
                                    bgColor: const Color(0xFFFFFDE7),
                                    borderColor: const Color(0xFFFFF9C4),
                                    desc: 'Deteksi bintik kematangan (sugar spots), kehitaman, dan pembusukan pada pisang.',
                                  ),
                                  _buildFruitAvatarItem(
                                    context: context,
                                    emoji: '🥭',
                                    name: 'Mangga',
                                    bgColor: const Color(0xFFFFF8E1),
                                    borderColor: const Color(0xFFFFECB3),
                                    desc: 'Deteksi kehalusan kulit, tingkat layu, dan bercak jamur pada mangga.',
                                  ),
                                  _buildFruitAvatarItem(
                                    context: context,
                                    emoji: '🍅',
                                    name: 'Tomat',
                                    bgColor: const Color(0xFFFBE9E7),
                                    borderColor: const Color(0xFFFFCCBC),
                                    desc: 'Deteksi warna merah segar, tekstur lembek berair, dan retak pada tomat.',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Section Tips Pemotretan Terbaik
                        const Text(
                          'Tips Akurasi AI',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildQuickTipCard(
                              icon: Icons.wb_sunny_rounded,
                              title: 'Cahaya Terang',
                              desc: 'Bebas bayangan',
                            ),
                            const SizedBox(width: 10),
                            _buildQuickTipCard(
                              icon: Icons.crop_free_rounded,
                              title: '1 Objek Buah',
                              desc: 'Tengah frame',
                            ),
                            const SizedBox(width: 10),
                            _buildQuickTipCard(
                              icon: Icons.wallpaper_rounded,
                              title: 'Latar Polos',
                              desc: 'Warna netral',
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Section Aktivitas Terakhir
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Aktivitas Terbaru',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => widget.onTabChange(2), // Tab Riwayat
                              child: const Text('Lihat Semua', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        statsAsync.when(
                          data: (data) {
                            if (data.recentScans.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFF0F0F0)),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8FAF8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.inventory_2_outlined,
                                          size: 32,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Belum ada hasil sortir buah',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Jepret foto buah pertamamu untuk melihat riwayat',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: data.recentScans.map((item) {
                                final file = File(item.imagePath);
                                final timeFormatted = AppDateFormatter.formatShort(item.createdAt);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFF0F0F0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.015),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: file.existsSync()
                                            ? Image.file(
                                                file,
                                                width: 52,
                                                height: 52,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 52,
                                                height: 52,
                                                color: AppColors.primaryLight,
                                                child: const Icon(
                                                  Icons.image_outlined,
                                                  color: AppColors.primaryGreen,
                                                ),
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
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Keyakinan: ${(item.confidence * 100).toInt()}% • $timeFormatted',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      QualityBadge(quality: item.quality),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (_, _) => const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildFruitAvatarItem({
    required BuildContext context,
    required String emoji,
    required String name,
    required Color bgColor,
    required Color borderColor,
    required String desc,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showFruitInfoModal(
          context: context,
          emoji: emoji,
          name: name,
          bgColor: bgColor,
          borderColor: borderColor,
          desc: desc,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'AI Ready',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFruitInfoModal({
    required BuildContext context,
    required String emoji,
    required String name,
    required Color bgColor,
    required Color borderColor,
    required String desc,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header info buah
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Buah $name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Didukung AI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Model siap sortir 3 tingkat kualitas',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deskripsi Ciri Analisis
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAF9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDF2EE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cakupan Analisis Computer Vision:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Status Mutu Chips (Bagus, Cukup, Busuk)
            const Row(
              children: [
                Expanded(
                  child: QualityBadge(quality: FruitQuality.bagus),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: QualityBadge(quality: FruitQuality.cukup),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: QualityBadge(quality: FruitQuality.busuk),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol Aksi Langsung Scan Buah Ini
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _startScan(context, ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: Text(
                  'Scan $name Sekarang',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildQuickTipCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildUnifiedStatCol({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 38,
      color: const Color(0xFFF0F4F0),
    );
  }

  static Widget _buildAppBarActionBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? bgColor,
    Color? iconColor,
    Border? border,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: border ?? Border.all(color: const Color(0xFFEDF2EE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 19, color: iconColor ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}
