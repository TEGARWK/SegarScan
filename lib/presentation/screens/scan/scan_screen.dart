import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/scan_state_provider.dart';
import '../../widgets/pak_segar_loading_widget.dart';
import '../result/result_screen.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scannerAnimController;
  late final Animation<double> _scannerAnimation;

  @override
  void initState() {
    super.initState();
    _scannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scannerAnimation = CurvedAnimation(
      parent: _scannerAnimController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scannerAnimController.dispose();
    super.dispose();
  }

  void _processImage(ImageSource source) async {
    HapticFeedback.lightImpact();
    final notifier = ref.read(scanStateProvider.notifier);
    await notifier.pickAndClassify(source);

    if (!mounted) return;

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
          content: Text(state.errorMessage ?? 'Gagal memproses gambar buah'),
          backgroundColor: AppColors.qualityBad,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanStateProvider);

    if (scanState.status == ScanStatus.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9F7),
        body: SafeArea(
          child: PakSegarLoadingWidget(
            title: 'Menganalisis Kualitas Buah...',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      body: Column(
        children: [
          // 1. Header Bersih & Segar Selaras Beranda
          _buildHeader(context),

          // 2. Viewfinder Lega & Tombol Aksi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  // AI Viewfinder Bersih & Luas
                  Expanded(
                    child: _buildAiViewfinder(),
                  ),

                  const SizedBox(height: 18),

                  // Tombol Aksi Kamera & Galeri
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF388E3C), // Hijau Segar identik dengan Hero Beranda
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
            left: 24,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Header Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Subjudul
                  const Text(
                    'Pindai Kualitas Buah',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Arahkan kamera ke buah untuk sortir mutu otomatis',
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

  Widget _buildAiViewfinder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5EDE5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boxSize = (constraints.maxHeight * 0.70).clamp(200.0, 270.0);

            return Stack(
              alignment: Alignment.center,
              children: [
                // Background subtle circular aura
                Container(
                  width: boxSize * 1.15,
                  height: boxSize * 1.15,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF1F8F1),
                  ),
                ),

                // Frame Viewfinder dengan Corner Brackets & Laser
                SizedBox(
                  width: boxSize,
                  height: boxSize,
                  child: Stack(
                    children: [
                      // Sudut 4 Brackets
                      CustomPaint(
                        size: Size(boxSize, boxSize),
                        painter: _ViewfinderCornerPainter(
                          color: const Color(0xFF388E3C),
                          cornerLength: 28,
                          strokeWidth: 3.5,
                        ),
                      ),

                      // Animasi Laser Scanning Line
                      AnimatedBuilder(
                        animation: _scannerAnimation,
                        builder: (context, child) {
                          final topPos = _scannerAnimation.value * (boxSize - 8);
                          return Positioned(
                            top: topPos,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 2.5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF66BB6A),
                                    Color(0xFF2E7D32),
                                    Color(0xFF66BB6A),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1.5,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Ikon Pusat Target AI Bersih
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.center_focus_strong_rounded,
                              size: 56,
                              color: const Color(0xFF388E3C).withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'AI Siap Deteksi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Pill Petunjuk di Bawah Frame
                Positioned(
                  bottom: 22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6F1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFDCE7DC),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 15,
                          color: Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Jarak ideal 20–30 cm • Cahaya cukup terang',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Buka Kamera (Solid Green)
        Expanded(
          flex: 6,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: const Color(0xFF388E3C).withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _processImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_rounded, size: 21),
            label: const Text(
              'Buka Kamera',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Tombol Dari Galeri (Outlined Green)
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
            onPressed: () => _processImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_rounded, size: 20),
            label: const Text(
              'Galeri',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter untuk 4 Sudut Corner Brackets pada Viewfinder
class _ViewfinderCornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  _ViewfinderCornerPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final l = cornerLength;

    // Top-Left Corner
    final pathTL = Path()
      ..moveTo(0, l)
      ..lineTo(0, 0)
      ..lineTo(l, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right Corner
    final pathTR = Path()
      ..moveTo(w - l, 0)
      ..lineTo(w, 0)
      ..lineTo(w, l);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left Corner
    final pathBL = Path()
      ..moveTo(0, h - l)
      ..lineTo(0, h)
      ..lineTo(l, h);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right Corner
    final pathBR = Path()
      ..moveTo(w - l, h)
      ..lineTo(w, h)
      ..lineTo(w, h - l);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderCornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
