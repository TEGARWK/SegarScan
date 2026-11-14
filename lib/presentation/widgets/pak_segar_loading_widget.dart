import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'pak_segar_widget.dart';

/// Loading view interaktif berkarakter Maskot Pak Segar
/// dengan Dynamic Speech Bubble dan AI Inspection Step Ticker.
class PakSegarLoadingWidget extends StatefulWidget {
  final String title;
  final String? subtitle;

  const PakSegarLoadingWidget({
    super.key,
    this.title = 'Menganalisis Kualitas Buah...',
    this.subtitle,
  });

  @override
  State<PakSegarLoadingWidget> createState() => _PakSegarLoadingWidgetState();
}

class _PakSegarLoadingWidgetState extends State<PakSegarLoadingWidget>
    with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  Timer? _stepTimer;
  String _pakSegarSpeech = 'Bentar ya, Pak Segar teropong dulu... 🔍';
  late final AnimationController _progressAnimController;

  final List<String> _aiSteps = [
    'Memindai tekstur, bercak & geometri buah...',
    'Mengekstraksi fitur visual citra...',
    'Menghitung tingkat kesegaran & mutu buah...',
  ];

  @override
  void initState() {
    super.initState();
    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    // Timer rotasi tahapan analisis AI tiap 800ms
    _stepTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      setState(() {
        _currentStepIndex = (_currentStepIndex + 1) % _aiSteps.length;
      });
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _progressAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE8ECE8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Kapsul Header Status AI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'AI VISION INSPECTION AKTIF',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. Balon Dialog Lucu Pak Segar (Speech Bubble)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: Container(
                key: ValueKey<String>(_pakSegarSpeech),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Text(
                  _pakSegarSpeech,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 3. Karakter Maskot "Pak Segar" Beranimasi Memeriksa Buah
            Stack(
              alignment: Alignment.center,
              children: [
                // Soft glow background aura
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE8F5E9).withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                PakSegarWidget(
                  width: 154,
                  height: 170,
                  pose: PakSegarPose.scanning,
                  showScannerBeam: true,
                  onSpeechChanged: (speech) {
                    if (mounted) {
                      setState(() {
                        _pakSegarSpeech = speech;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 4. Judul Loading
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 8),

            // 5. Dynamic AI Step Ticker (Animasi Tahapan Analisis)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Row(
                key: ValueKey<int>(_currentStepIndex),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      _aiSteps[_currentStepIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 6. Indikator Progress Garis Halus
            AnimatedBuilder(
              animation: _progressAnimController,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progressAnimController.value * 0.95,
                    backgroundColor: const Color(0xFFE8F5E9),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    minHeight: 5,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 7. Catatan Kecepatan Inferensi
            const Text(
              '⚡ Pak Segar sedang memeriksa mutu buah (~2.5 dtk)',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
