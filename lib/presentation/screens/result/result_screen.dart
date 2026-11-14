import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/fruit_constants.dart';
import '../../../data/models/fruit_quality.dart';
import '../../../data/models/prediction_result.dart';
import '../../../providers/history_provider.dart';
import '../../widgets/pak_segar_widget.dart';
import '../../widgets/quality_badge.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final PredictionResult prediction;
  final File imageFile;

  const ResultScreen({
    super.key,
    required this.prediction,
    required this.imageFile,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isSaved = false;

  void _saveToHistory() async {
    if (_isSaved) return;

    HapticFeedback.lightImpact();
    await ref.read(historyProvider.notifier).savePrediction(
          prediction: widget.prediction,
          imagePath: widget.imageFile.path,
        );

    if (!mounted) return;

    setState(() {
      _isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Hasil sortir berhasil disimpan ke riwayat!'),
          ],
        ),
        backgroundColor: AppColors.qualityGood,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  String _getConfidenceCategory(double conf) {
    if (conf >= 0.85) return 'Akurasi Sangat Tinggi';
    if (conf >= 0.70) return 'Akurasi Tinggi';
    if (conf >= 0.55) return 'Akurasi Cukup';
    return 'Akurasi Rendah (Disarankan Foto Ulang)';
  }

  String _getPakSegarAdvice(FruitQuality quality, String fruit) {
    final fruitCapital = FruitConstants.formatFruitName(fruit);
    switch (quality) {
      case FruitQuality.bagus:
        return 'Mulus dan segar prima! Buah $fruitCapital ini sangat layak dijual di etalase toko atau langsung dikonsumsi keluarga. 👍';
      case FruitQuality.cukup:
        return 'Kematangan sudah maksimal dan permukaan mulai melunak. Sebaiknya segera dikonsumsi hari ini atau diolah menjadi jus! 🍹';
      case FruitQuality.busuk:
        return 'Waduh, terdeteksi tanda kerusakan/pembusukan aktif. Segera pisahkan dari keranjang agar spora tidak menular ke buah lain! ⚠️';
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

  @override
  Widget build(BuildContext context) {
    final pred = widget.prediction;
    final isLowConfidence = pred.confidence < 0.60;
    final guidelines = _getActionGuidelines(pred.quality);
    final fruitEmoji = _getFruitEmoji(pred.fruit);
    final confPercent = (pred.confidence * 100).toInt();

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
          'Hasil Klasifikasi',
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
                onTap: _saveToHistory,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isSaved ? const Color(0xFFE8F5E9) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSaved
                          ? AppColors.primaryGreen.withValues(alpha: 0.3)
                          : const Color(0xFFE8ECE8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isSaved
                        ? Icons.bookmark_added_rounded
                        : Icons.bookmark_border_rounded,
                    color: _isSaved ? AppColors.primaryGreen : AppColors.textPrimary,
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
          // 1. Preview Foto Buah dengan Overlay Badges Modern
          _buildPhotoPreviewCard(pred),

          const SizedBox(height: 18),

          // 2. Hero Card Hasil Klasifikasi & Status Mutu
          _buildMainResultCard(pred, fruitEmoji, confPercent, isLowConfidence),

          const SizedBox(height: 16),

          // 3. Catatan & Reaksi Maskot Pak Segar
          _buildPakSegarNoteCard(pred),

          const SizedBox(height: 16),

          // 4. Panduan Penanganan & Tindakan Sortir (Actionable Insights)
          _buildActionGuidelinesCard(pred, guidelines),

          const SizedBox(height: 16),

          // 5. Spesifikasi Teknis AI & Komputer Vision
          _buildTechnicalAiCard(pred),

          const SizedBox(height: 24),

          // 6. Tombol Aksi Bawah (Scan Lagi & Simpan Riwayat)
          _buildBottomActionButtons(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Card Foto Buah dengan Badges Pintar di Sudut-sudutnya
  Widget _buildPhotoPreviewCard(PredictionResult pred) {
    return Container(
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
              Image.file(
                widget.imageFile,
                fit: BoxFit.cover,
              ),

              // Gradient Overlay Halus dari Atas dan Bawah
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

              // Badge Kiri Atas: AI Vision Verification
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
                      const Icon(Icons.auto_awesome, color: Color(0xFF81C784), size: 14),
                      const SizedBox(width: 5),
                      Text(
                        'AI Vision • ${pred.inferenceTimeMs} ms',
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

              // Badge Kanan Bawah: Label Kualitas Buah
              Positioned(
                bottom: 14,
                right: 14,
                child: QualityBadge(quality: pred.quality, isLarge: false),
              ),

              // Badge Kiri Bawah: Identitas Buah
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
                      Text(
                        _getFruitEmoji(pred.fruit),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        FruitConstants.formatFruitName(pred.fruit),
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
    );
  }

  /// Card Utama: Nama Buah, Status Mutu, Keyakinan AI, dan Distribusi Kelas
  Widget _buildMainResultCard(
    PredictionResult pred,
    String fruitEmoji,
    int confPercent,
    bool isLowConfidence,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8EFE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris: Nama Buah & Badge Kualitas Besar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      FruitConstants.formatFruitName(pred.fruit),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kategori: ${FruitConstants.getQualityLabel(pred.quality.name)}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: pred.quality.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              QualityBadge(quality: pred.quality, isLarge: true),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF0F4F0)),
          const SizedBox(height: 18),

          // Baris Tingkat Keyakinan (Confidence Score)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tingkat Keyakinan AI',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getConfidenceCategory(pred.confidence),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isLowConfidence ? AppColors.qualityFair : AppColors.textMuted,
                      fontWeight: isLowConfidence ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Text(
                '$confPercent%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: pred.quality.color,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress Bar Indikator Tingkat Keyakinan
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pred.confidence,
              minHeight: 10,
              backgroundColor: const Color(0xFFECEFE8),
              valueColor: AlwaysStoppedAnimation<Color>(pred.quality.color),
            ),
          ),

          // Peringatan jika tingkat keyakinan rendah (<60%)
          if (isLowConfidence) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFF57F17), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tingkat keyakinan di bawah 60%. Disarankan untuk memotret ulang di pencahayaan yang lebih terang.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),

          // Distribusi Probabilitas 3 Kelas dengan Mini Meter Bar
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
                value: pred.probabilities['bagus'] ?? 0.0,
                color: AppColors.qualityGood,
                bgColor: const Color(0xFFE8F5E9),
                isSelected: pred.quality == FruitQuality.bagus,
              ),
              const SizedBox(width: 8),
              _buildModernProbCard(
                label: 'Cukup',
                value: pred.probabilities['cukup'] ?? 0.0,
                color: AppColors.qualityFair,
                bgColor: const Color(0xFFFFF8E1),
                isSelected: pred.quality == FruitQuality.cukup,
              ),
              const SizedBox(width: 8),
              _buildModernProbCard(
                label: 'Busuk',
                value: pred.probabilities['busuk'] ?? 0.0,
                color: AppColors.qualityBad,
                bgColor: const Color(0xFFFFEBEE),
                isSelected: pred.quality == FruitQuality.busuk,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mini Card Probabilitas Modern dengan Meter Progres Internal
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_circle, size: 11, color: color),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
              ],
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

  /// Card Komentar & Reaksi Maskot Pak Segar
  Widget _buildPakSegarNoteCard(PredictionResult pred) {
    return Container(
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
                pose: _getPakSegarPose(pred.quality),
                fixedQuality: _getPakSegarQuality(pred.quality),
                fruitType: pred.fruit,
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
                const Row(
                  children: [
                    Text(
                      'Catatan Pak Segar',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '• Petugas Sortir',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getPakSegarAdvice(pred.quality, pred.fruit),
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

  /// Card Panduan Penanganan & Tindakan Sortir (3 Poin Praktis)
  Widget _buildActionGuidelinesCard(
    PredictionResult pred,
    Map<String, String> guidelines,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: Color(0xFF388E3C),
                size: 20,
              ),
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

  /// Spesifikasi Teknis AI & Computer Vision
  Widget _buildTechnicalAiCard(PredictionResult pred) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EDE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.memory_rounded, size: 16, color: AppColors.textMuted),
              SizedBox(width: 6),
              Text(
                'Metrik Teknis Computer Vision',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTechParam(
                  label: 'Kecepatan Inferensi',
                  value: '${pred.inferenceTimeMs} ms',
                ),
              ),
              Container(width: 1, height: 26, color: const Color(0xFFE0E6E0)),
              Expanded(
                child: _buildTechParam(
                  label: 'Arsitektur Model',
                  value: 'MobileNetV3',
                ),
              ),
              Container(width: 1, height: 26, color: const Color(0xFFE0E6E0)),
              Expanded(
                child: _buildTechParam(
                  label: 'Status Validasi',
                  value: 'Tervalidasi',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechParam({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  /// Tombol Aksi Bawah: Scan Lagi & Simpan Riwayat
  Widget _buildBottomActionButtons() {
    return Row(
      children: [
        // Tombol Scan Lagi (Outlined Green)
        Expanded(
          flex: 5,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
              backgroundColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFF388E3C),
                width: 1.8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text(
              'Scan Lagi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Tombol Simpan Riwayat (Solid Green)
        Expanded(
          flex: 6,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSaved ? const Color(0xFF78909C) : const Color(0xFF388E3C),
              foregroundColor: Colors.white,
              elevation: _isSaved ? 0 : 2,
              shadowColor: const Color(0xFF388E3C).withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isSaved ? null : _saveToHistory,
            icon: Icon(
              _isSaved ? Icons.check_circle_rounded : Icons.bookmark_add_rounded,
              size: 20,
            ),
            label: Text(
              _isSaved ? 'Tersimpan' : 'Simpan Riwayat',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
