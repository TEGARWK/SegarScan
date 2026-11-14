import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum kualitas buah yang diperiksa oleh Pak Segar
enum PakSegarQuality { bagus, cukup, busuk }

/// Enum pose/karakter Pak Segar agar fleksibel di berbagai layar (Loading, Result, Home, dll)
enum PakSegarPose {
  /// Loop animasi memeriksa buah dari keranjang (default di beranda)
  inspecting,

  /// Mode pemindaian AI intensif dengan sinar laser hologram dari kaca pembesar (untuk loading)
  scanning,

  /// Pose bahagia mengacungkan jempol / buah prima (untuk hasil buah BAGUS)
  happy,

  /// Pose berpikir mengamati tekstur buah (untuk hasil buah CUKUP)
  thinking,

  /// Pose cemas/waspada memperingatkan pembusukan (untuk hasil buah BUSUK)
  worried,
}

/// Widget Karakter Maskot "Pak Segar" — Petugas sortir AI SegarScan
/// yang interaktif, ekspresif, dengan animasi Inverse Kinematics,
/// kaca pembesar AI, sinar pemindai laser, dan variasi buah.
class PakSegarWidget extends StatefulWidget {
  final double width;
  final double height;
  final ValueChanged<String>? onSpeechChanged;
  final PakSegarPose? pose;
  final PakSegarQuality? fixedQuality;
  final String? fruitType;
  final bool? interactive;
  final bool? showScannerBeam;

  const PakSegarWidget({
    super.key,
    this.width = 280,
    this.height = 190,
    this.onSpeechChanged,
    this.pose = PakSegarPose.inspecting,
    this.fixedQuality,
    this.fruitType = 'apel',
    this.interactive = true,
    this.showScannerBeam = true,
  });

  PakSegarPose get effectivePose => pose ?? PakSegarPose.inspecting;
  String get effectiveFruitType => fruitType ?? 'apel';
  bool get effectiveInteractive => interactive ?? true;
  bool get effectiveShowScannerBeam => showScannerBeam ?? true;

  @override
  State<PakSegarWidget> createState() => _PakSegarWidgetState();
}

class _PakSegarWidgetState extends State<PakSegarWidget>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  // State karakter
  late PakSegarQuality _currentQuality;
  String _speechText = 'Diperiksa dulu...';
  double _blinkScale = 0.0;

  static const Offset _basketTarget = Offset(340, 296);
  static const Offset _inspectTarget = Offset(335, 142);

  int _lastCycle = -1;
  final Random _random = Random();

  final List<String> _greetings = [
    'Halo! Aku Pak Segar, siap menyortir buah terbaik untukmu! 🥑',
    'Tips: Simpan buah di tempat kering dan sejuk agar tahan lama! 🍎',
    'Buah segar memiliki aroma alami tanpa bau asam atau busuk. 🍊',
    'Kulit buah yang mulus menandakan vitamin masih utuh terjaga! ✨',
    'Sortir rutin menjaga stok buah tokomu tetap berkualitas tinggi! 🍌',
  ];

  @override
  void initState() {
    super.initState();
    _currentQuality = widget.fixedQuality ?? PakSegarQuality.bagus;

    // Loop animasi karakter
    final durationMs = widget.effectivePose == PakSegarPose.scanning ? 3200 : 5400;
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..addListener(_onFrameUpdate);

    _animController.repeat();

    // Animasi bounce saat ditap
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 60),
    ]).animate(_bounceController);

    _scheduleBlink();
  }

  @override
  void didUpdateWidget(covariant PakSegarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fixedQuality != null) {
      _currentQuality = widget.fixedQuality!;
    }
  }

  void _scheduleBlink() {
    Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(2500)), () {
      if (!mounted) return;
      setState(() => _blinkScale = 1.0);
      Future.delayed(const Duration(milliseconds: 130), () {
        if (!mounted) return;
        setState(() => _blinkScale = 0.0);
        _scheduleBlink();
      });
    });
  }

  void _onFrameUpdate() {
    if (widget.fixedQuality != null) {
      _currentQuality = widget.fixedQuality!;
    } else {
      final cycle = (_animController.lastElapsedDuration?.inMilliseconds ?? 0) ~/ 5400;
      if (cycle != _lastCycle) {
        _lastCycle = cycle;
        final qualities = PakSegarQuality.values;
        _currentQuality = qualities[(_currentQuality.index + 1) % qualities.length];
      }
    }

    final p = _animController.value;
    String newSpeech;

    final currentPose = widget.effectivePose;
    if (currentPose == PakSegarPose.scanning) {
      if (p < 0.33) {
        newSpeech = 'Memindai geometri & kontur buah... 🔍';
      } else if (p < 0.66) {
        newSpeech = 'Mengekstrak tekstur & warna kulit... ✨';
      } else {
        newSpeech = 'Menilai tingkat kesegaran mutunya... 🥑';
      }
    } else if (currentPose == PakSegarPose.happy) {
      newSpeech = 'Mulus dan segar! Ini layak jual. 🍎';
    } else if (currentPose == PakSegarPose.thinking) {
      newSpeech = 'Kematangan maksimal, segera konsumsi ya. 🍊';
    } else if (currentPose == PakSegarPose.worried) {
      newSpeech = 'Terdeteksi kerusakan, pisahkan ya! 🥀';
    } else {
      if (p > 0.34 && p < 0.90) {
        switch (_currentQuality) {
          case PakSegarQuality.bagus:
            newSpeech = 'Mulus dan segar! Ini layak jual. 🍎';
            break;
          case PakSegarQuality.cukup:
            newSpeech = 'Hmm, mulai kusam. Jual cepat ya. 🍊';
            break;
          case PakSegarQuality.busuk:
            newSpeech = 'Yah, sudah busuk... pisahkan ya. 🥀';
            break;
        }
      } else if (p < 0.10) {
        newSpeech = 'Mengambil buah dari keranjang...';
      } else if (p < 0.34) {
        newSpeech = 'Diperiksa dulu kualitasnya... 🔍';
      } else {
        newSpeech = 'Dikembalikan ke keranjang...';
      }
    }

    if (newSpeech != _speechText) {
      setState(() {
        _speechText = newSpeech;
      });
      widget.onSpeechChanged?.call(newSpeech);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onTapMascot() {
    if (!widget.effectiveInteractive) return;

    HapticFeedback.selectionClick();
    _bounceController.forward(from: 0.0);

    final randomGreeting = _greetings[_random.nextInt(_greetings.length)];
    setState(() {
      _speechText = randomGreeting;
    });
    widget.onSpeechChanged?.call(randomGreeting);
  }

  double _ease(double t) {
    return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2;
  }

  Offset _lerpOffset(Offset a, Offset b, double t) {
    return Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTapMascot,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animController, _bounceAnimation]),
        builder: (context, child) {
          final p = _animController.value;

          Offset target = _basketTarget;
          double fruitScale = 1.0;
          double fruitWobble = 0.0;

          double magnifierWeight = 0.0;
          final pose = widget.effectivePose;
          if (pose == PakSegarPose.happy ||
              pose == PakSegarPose.thinking ||
              pose == PakSegarPose.worried) {
            // Pose statis ekspresif dengan napas halus
            target = Offset(335, 142 + sin(p * 2 * pi) * 6);
            fruitScale = 1.0;
            fruitWobble = sin(p * 2 * pi) * 0.05;
            magnifierWeight = pose == PakSegarPose.worried ? 0.0 : 1.0;
          } else if (pose == PakSegarPose.scanning) {
            // Mode pemindaian AI aktif (menginspeksi buah secara dinamis & aktif)
            final scanCycle = p * 2 * pi * 2; // 2 putaran pemindaian dinamis
            target = Offset(
              335 + cos(scanCycle) * 6,
              142 + sin(scanCycle) * 10,
            );
            fruitScale = 1.0;
            fruitWobble = sin(scanCycle) * 0.12;
            magnifierWeight = 1.0;
          } else {
            // Loop dinamis
            if (p < 0.10) {
              fruitScale = _ease(p / 0.10);
            } else if (p < 0.34) {
              final k = _ease((p - 0.10) / 0.24);
              target = _lerpOffset(_basketTarget, _inspectTarget, k);
            } else if (p < 0.72) {
              final u = (p - 0.34) / 0.38;
              target = Offset(
                _inspectTarget.dx,
                _inspectTarget.dy + sin(u * pi * 5) * 14,
              );
              fruitWobble = sin(u * pi * 5) * 0.1;
            } else if (p < 0.92) {
              final k = _ease((p - 0.72) / 0.20);
              target = _lerpOffset(_inspectTarget, _basketTarget, k);
            } else {
              fruitScale = 1.0 - _ease((p - 0.92) / 0.08);
            }

            // Transisi mulus mengangkat & menurunkan kaca pembesar (tidak mendadak)
            if (p < 0.18) {
              magnifierWeight = 0.0;
            } else if (p < 0.34) {
              // Mengangkat kaca pembesar secara halus seiring buah naik
              magnifierWeight = _ease((p - 0.18) / 0.16);
            } else if (p < 0.74) {
              // Menatap buah dengan kaca pembesar penuh
              magnifierWeight = 1.0;
            } else if (p < 0.90) {
              // Menurunkan kaca pembesar kembali ke samping secara halus
              magnifierWeight = 1.0 - _ease((p - 0.74) / 0.16);
            } else {
              magnifierWeight = 0.0;
            }
          }

          fruitScale = fruitScale.clamp(0.001, 1.0);
          magnifierWeight = magnifierWeight.clamp(0.0, 1.0);

          return ScaleTransition(
            scale: _bounceAnimation,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: CustomPaint(
                painter: _PakSegarPainter(
                  targetHand: target,
                  fruitScale: fruitScale,
                  fruitWobble: fruitWobble,
                  quality: _currentQuality,
                  blinkScale: _blinkScale,
                  progress: p,
                  pose: pose,
                  fruitType: widget.effectiveFruitType,
                  showScannerBeam: widget.effectiveShowScannerBeam,
                  magnifierWeight: magnifierWeight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// CustomPainter yang menggambar seluruh visual vector Pak Segar,
/// kaca pembesar AI dengan beam laser, dan ragam buah
class _PakSegarPainter extends CustomPainter {
  final Offset targetHand;
  final double fruitScale;
  final double fruitWobble;
  final PakSegarQuality quality;
  final double blinkScale;
  final double progress;
  final PakSegarPose pose;
  final String fruitType;
  final bool showScannerBeam;
  final double magnifierWeight;

  _PakSegarPainter({
    required this.targetHand,
    required this.fruitScale,
    required this.fruitWobble,
    required this.quality,
    required this.blinkScale,
    required this.progress,
    required this.pose,
    required this.fruitType,
    required this.showScannerBeam,
    required this.magnifierWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cropLeft = 142.0;
    const cropTop = 46.0;
    const cropWidth = 258.0;
    const cropHeight = 318.0;

    final scaleX = size.width / cropWidth;
    final scaleY = size.height / cropHeight;
    final scale = min(scaleX, scaleY);

    canvas.save();
    final offsetX = (size.width - cropWidth * scale) / 2;
    final offsetY = (size.height - cropHeight * scale) / 2;
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);
    canvas.translate(-cropLeft, -cropTop);

    // 1. Bayangan Lantai
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.12);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(275, 350), width: 250, height: 24),
      shadowPaint,
    );

    // 2. Kaki & Sepatu
    final legPaint = Paint()..color = const Color(0xFF37474F);
    final shoePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(190, 296, 28, 48), const Radius.circular(9)),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(222, 296, 28, 48), const Radius.circular(9)),
      legPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(183, 336, 40, 14), const Radius.circular(7)),
      shoePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(217, 336, 40, 14), const Radius.circular(7)),
      shoePaint,
    );

    // 3. Leher + Badan (Baju Hijau Petugas SegarScan)
    final skinDarkPaint = Paint()..color = const Color(0xFFE5A574);
    final bodyGreenPaint = Paint()..color = const Color(0xFF43A047);
    final shirtWhitePaint = Paint()..color = const Color(0xFFF5F1E6);

    // Leher
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(206, 158, 28, 30), const Radius.circular(8)),
      skinDarkPaint,
    );

    // Rompi / Baju Hijau (dengan shading samping)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(162, 176, 116, 130), const Radius.circular(34)),
      bodyGreenPaint,
    );

    // Kerah
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(220, 178), width: 34, height: 18),
      skinDarkPaint,
    );

    // Kaos/Kemeja Putih Tengah
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(188, 198, 64, 106), const Radius.circular(12)),
      shirtWhitePaint,
    );

    // Tali selempang kemeja
    final strapPaint = Paint()
      ..color = const Color(0xFFE6DECA)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(196, 200), const Offset(203, 180), strapPaint);
    canvas.drawLine(const Offset(244, 200), const Offset(237, 180), strapPaint);

    // Lambang Daun SegarScan di Dada
    final badgeLeafPath = Path();
    badgeLeafPath.moveTo(220, 232);
    badgeLeafPath.quadraticBezierTo(208, 228, 206, 216);
    badgeLeafPath.quadraticBezierTo(218, 216, 220, 232);
    badgeLeafPath.quadraticBezierTo(222, 220, 234, 218);
    badgeLeafPath.quadraticBezierTo(232, 230, 220, 232);
    canvas.drawPath(badgeLeafPath, bodyGreenPaint);

    // ID Card Petugas
    final idCardPaint = Paint()
      ..color = const Color(0xFFD6CFBA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(203, 256, 34, 26), const Radius.circular(6)),
      idCardPaint,
    );
    // Foto mini di ID card
    final idPhoto = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(const Offset(212, 269), 5, idPhoto);

    // 4. Keranjang Belakang & Buah Cadangan
    final basketBackPaint = Paint()..color = const Color(0xFF8D6232);
    canvas.drawRect(const Rect.fromLTWH(302, 292, 88, 20), basketBackPaint);

    _drawFruitMini(canvas, const Offset(322, 296), const Color(0xFFE53935), 'apel');
    _drawFruitMini(canvas, const Offset(346, 290), const Color(0xFFFF9800), 'jeruk');
    _drawFruitMini(canvas, const Offset(370, 297), const Color(0xFF4CAF50), 'mangga');

    // 5. Inverse Kinematics Lengan Kanan (Memegang Buah)
    const shoulder = Offset(268, 196);
    const armLen = 63.0;

    final dx = targetHand.dx - shoulder.dx;
    final dy = targetHand.dy - shoulder.dy;
    final dst = sqrt(dx * dx + dy * dy);
    final dd = min(dst, 2 * armLen - 0.01);
    final h = sqrt(max(0.0, armLen * armLen - dd * dd / 4));
    final ux = dx / (dst == 0 ? 1 : dst);
    final uy = dy / (dst == 0 ? 1 : dst);
    final mx = shoulder.dx + ux * dd / 2;
    final my = shoulder.dy + uy * dd / 2;
    final elbow = Offset(mx - uy * h, my + ux * h);
    final hand = Offset(shoulder.dx + ux * dd, shoulder.dy + uy * dd);

    final armRightGreen = Paint()
      ..color = const Color(0xFF43A047)
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final armRightSkin = Paint()
      ..color = const Color(0xFFF2B98A)
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(shoulder, elbow, armRightGreen);
    canvas.drawLine(elbow, hand, armRightSkin);

    // Buah di Genggaman Tangan Kanan
    final fruitCenter = Offset(hand.dx, hand.dy - 20 + (1.0 - fruitScale) * 14);
    canvas.save();
    canvas.translate(fruitCenter.dx, fruitCenter.dy);
    canvas.rotate(fruitWobble);
    canvas.scale(fruitScale * 0.44, fruitScale * 0.44);
    _drawInspectedFruit(canvas, quality, fruitType);
    canvas.restore();

    // Telapak Tangan Kanan
    final skinPaint = Paint()..color = const Color(0xFFF2B98A);
    canvas.drawCircle(hand, 12, skinPaint);

    // 6. Keranjang Depan (Anyaman Rotan)
    final basketFrontPaint = Paint()..color = const Color(0xFFA1763F);
    final basketWeavePaint = Paint()
      ..color = const Color(0xFF8D6232)
      ..strokeWidth = 3;

    final basketPath = Path();
    basketPath.moveTo(298, 304);
    basketPath.lineTo(394, 304);
    basketPath.lineTo(386, 346);
    basketPath.quadraticBezierTo(344, 352, 306, 346);
    basketPath.close();
    canvas.drawPath(basketPath, basketFrontPaint);

    canvas.drawLine(const Offset(302, 320), const Offset(390, 320), basketWeavePaint);
    canvas.drawLine(const Offset(304, 334), const Offset(388, 334), basketWeavePaint);
    canvas.drawLine(const Offset(322, 306), const Offset(322, 348), basketWeavePaint);
    canvas.drawLine(const Offset(346, 306), const Offset(346, 350), basketWeavePaint);
    canvas.drawLine(const Offset(370, 306), const Offset(370, 348), basketWeavePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(294, 298, 104, 12), const Radius.circular(6)),
      basketBackPaint,
    );

    // Status apakah Pak Segar sedang dalam fase memeriksa buah
    final isInspectingFruit = magnifierWeight > 0.4;

    // 7. Kepala Pak Segar (digambar terlebih dahulu agar tidak menimpa kaca pembesar)
    final headDx = fruitCenter.dx - 220;
    final headDy = fruitCenter.dy - 120;
    final headDist = sqrt(headDx * headDx + headDy * headDy).clamp(1.0, 999.0);
    final eyeOffsetX = (headDx / headDist * 5).clamp(-5.0, 5.0);
    final eyeOffsetY = (headDy / headDist * 5).clamp(-5.0, 5.0);
    final headTilt = ((fruitCenter.dx - 220) / 14).clamp(0.0, 8.0) * pi / 180;
    final headBob = ((fruitCenter.dy - 120) / -50).clamp(-3.0, 3.0);

    canvas.save();
    canvas.translate(220, 175);
    canvas.rotate(headTilt);
    canvas.translate(-220, -175 + headBob);

    _drawHead(
      canvas: canvas,
      eyeOffsetX: eyeOffsetX,
      eyeOffsetY: eyeOffsetY,
      blink: blinkScale,
      quality: quality,
      isInspecting: isInspectingFruit,
    );

    canvas.restore();

    // 8. Tangan Kiri + Kaca Pembesar AI (bergerak halus naik & turun seiring siklus)
    _drawLeftArmAndMagnifier(
      canvas: canvas,
      fruitCenter: fruitCenter,
      magnifierWeight: magnifierWeight,
      progress: progress,
    );

    canvas.restore();
  }

  /// Gambar Tangan Kiri Memegang Kaca Pembesar AI yang bergerak halus (IK Smooth Interpolation)
  void _drawLeftArmAndMagnifier({
    required Canvas canvas,
    required Offset fruitCenter,
    required double magnifierWeight,
    required double progress,
  }) {
    final armGreen = Paint()
      ..color = const Color(0xFF43A047)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    final armSkin = Paint()
      ..color = const Color(0xFFF2B98A)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final skinPaint = Paint()..color = const Color(0xFFF2B98A);

    const shoulderL = Offset(172, 196);
    const armLen = 63.0;

    // Posisi istirahat di samping pinggul
    const restHand = Offset(162, 284);
    const restElbow = Offset(160, 244);

    if (magnifierWeight <= 0.001) {
      // Posisi santai murni di samping
      canvas.drawLine(const Offset(168, 200), restElbow, armGreen);
      canvas.drawLine(restElbow, restHand, armSkin);
      canvas.drawCircle(const Offset(162, 290), 13, skinPaint);
      return;
    }

    // Posisi periksa aktif di depan buah
    final inspectLens = Offset(fruitCenter.dx - 36, fruitCenter.dy);
    final inspectHand = inspectLens + const Offset(-12, 28);

    // Interpolasi halus posisi telapak tangan dari pinggul ke depan buah (tanpa teleportasi)
    final currentHand = Offset.lerp(restHand, inspectHand, magnifierWeight)!;

    // Inverse Kinematics lengan kiri yang bergerak dinamis dan mulus
    final dx = currentHand.dx - shoulderL.dx;
    final dy = currentHand.dy - shoulderL.dy;
    final dst = sqrt(dx * dx + dy * dy);
    final dd = min(dst, 2 * armLen - 0.01);
    final h = sqrt(max(0.0, armLen * armLen - dd * dd / 4));
    final ux = dx / (dst == 0 ? 1 : dst);
    final uy = dy / (dst == 0 ? 1 : dst);
    final mx = shoulderL.dx + ux * dd / 2;
    final my = shoulderL.dy + uy * dd / 2;

    final elbowL = Offset(mx - uy * h, my + ux * h);

    // Gambar lengan kiri (bahu -> siku -> tangan)
    canvas.drawLine(shoulderL, elbowL, armGreen);
    canvas.drawLine(elbowL, currentHand, armSkin);

    // Gambar Kaca Pembesar di tangan (muncul & mengecil secara halus seiring gerakan tangan)
    canvas.save();
    canvas.translate(currentHand.dx, currentHand.dy);
    canvas.scale(magnifierWeight, magnifierWeight);
    canvas.translate(-currentHand.dx, -currentHand.dy);

    final lensCenter = currentHand - const Offset(-12, 28);
    final handleTop = lensCenter + const Offset(-6, 14);

    // Tangkai Kaca Pembesar
    final handlePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(currentHand, handleTop, handlePaint);

    // Ring Lensa Kaca Pembesar
    final rimPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(lensCenter, 20, rimPaint);

    // Kaca Transparan dengan pantulan cyan
    final glassPaint = Paint()
      ..color = const Color(0xFF80DEEA).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lensCenter, 18, glassPaint);

    // Kilau kaca
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: lensCenter, radius: 14),
      -pi / 4,
      pi / 2,
      false,
      glintPaint,
    );

    canvas.restore();

    // Telapak tangan memegang pangkal gagang
    canvas.drawCircle(currentHand, 11, skinPaint);
  }

  void _drawHead({
    required Canvas canvas,
    required double eyeOffsetX,
    required double eyeOffsetY,
    required double blink,
    required PakSegarQuality quality,
    required bool isInspecting,
  }) {
    canvas.save();
    canvas.translate(-20, 0);

    final skinPaint = Paint()..color = const Color(0xFFF2B98A);
    final skinShadow = Paint()..color = const Color(0xFFE5A574);
    final capGreen = Paint()..color = const Color(0xFF2E7D32);
    final capDark = Paint()..color = const Color(0xFF256427);

    // Wajah & Telinga
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(240, 118), width: 108, height: 116),
      skinPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(187, 122), width: 18, height: 26),
      skinShadow,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(293, 122), width: 18, height: 26),
      skinShadow,
    );

    // Topi Hijau Petugas SegarScan
    final capPath = Path();
    capPath.moveTo(186, 98);
    capPath.quadraticBezierTo(186, 52, 240, 50);
    capPath.quadraticBezierTo(294, 52, 294, 98);
    capPath.quadraticBezierTo(240, 84, 186, 98);
    capPath.close();
    canvas.drawPath(capPath, capGreen);

    // Visor Topi
    final visorPath = Path();
    visorPath.moveTo(262, 92);
    visorPath.quadraticBezierTo(300, 84, 318, 98);
    visorPath.quadraticBezierTo(290, 106, 262, 100);
    visorPath.close();
    canvas.drawPath(visorPath, capDark);

    // Emblem Putih di Topi + Ceklis Hijau
    final badgeWhite = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(const Offset(240, 72), 14, badgeWhite);

    final checkPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final checkPath = Path();
    checkPath.moveTo(233, 72);
    checkPath.lineTo(238, 77);
    checkPath.lineTo(247, 67);
    canvas.drawPath(checkPath, checkPaint);

    // Mata Putih
    final eyeWhite = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(219, 120), 12, eyeWhite);
    canvas.drawCircle(const Offset(261, 120), 12, eyeWhite);

    // Pupil Hitam yang melirik buah
    final pupilPaint = Paint()..color = const Color(0xFF16341F);
    canvas.drawCircle(Offset(219 + eyeOffsetX, 120 + eyeOffsetY), 6, pupilPaint);
    canvas.drawCircle(Offset(261 + eyeOffsetX, 120 + eyeOffsetY), 6, pupilPaint);

    // Pantulan kilau mata (sparkle)
    final sparklePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(218 + eyeOffsetX, 118 + eyeOffsetY), 2, sparklePaint);
    canvas.drawCircle(Offset(260 + eyeOffsetX, 118 + eyeOffsetY), 2, sparklePaint);

    // Kelopak Mata (Berkedip)
    if (blink > 0.05) {
      final lidRectL = Rect.fromCenter(
        center: const Offset(219, 120),
        width: 28,
        height: 28 * blink,
      );
      final lidRectR = Rect.fromCenter(
        center: const Offset(261, 120),
        width: 28,
        height: 28 * blink,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(lidRectL, const Radius.circular(14)), skinPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(lidRectR, const Radius.circular(14)), skinPaint);
    }

    // Pipi Kemerahan (Blush)
    final blushPaint = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(203, 142), width: 18, height: 12),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(277, 142), width: 18, height: 12),
      blushPaint,
    );

    // Alis & Mulut
    final browPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mouthPaint = Paint()
      ..color = const Color(0xFF6D2F2F)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final browL = Path();
    final browR = Path();
    final mouth = Path();

    if (!isInspecting && pose != PakSegarPose.happy && pose != PakSegarPose.thinking && pose != PakSegarPose.worried) {
      // Netral
      browL.moveTo(205, 100);
      browL.quadraticBezierTo(219, 94, 233, 100);
      browR.moveTo(247, 100);
      browR.quadraticBezierTo(261, 94, 275, 100);

      mouth.moveTo(226, 152);
      mouth.quadraticBezierTo(240, 159, 254, 152);
    } else {
      switch (quality) {
        case PakSegarQuality.bagus:
          // Senyum lebar puas
          browL.moveTo(205, 98);
          browL.quadraticBezierTo(219, 92, 233, 98);
          browR.moveTo(247, 98);
          browR.quadraticBezierTo(261, 92, 275, 98);

          mouth.moveTo(224, 150);
          mouth.quadraticBezierTo(240, 168, 256, 150);
          break;

        case PakSegarQuality.cukup:
          // Alis agak berpikir, mulut datar
          browL.moveTo(205, 96);
          browL.quadraticBezierTo(219, 94, 233, 102);
          browR.moveTo(247, 100);
          browR.quadraticBezierTo(261, 96, 275, 100);

          mouth.moveTo(228, 156);
          mouth.lineTo(252, 156);
          break;

        case PakSegarQuality.busuk:
          // Alis sedih, mulut melengkung sedih
          browL.moveTo(205, 105);
          browL.quadraticBezierTo(219, 94, 233, 94);
          browR.moveTo(247, 94);
          browR.quadraticBezierTo(261, 94, 275, 105);

          mouth.moveTo(226, 160);
          mouth.quadraticBezierTo(240, 150, 254, 160);

          // Air mata menetes sedih
          final tearPaint = Paint()..color = const Color(0xFF6EC6FF);
          final tear = Path();
          tear.moveTo(213, 138);
          tear.quadraticBezierTo(208, 147, 213, 150);
          tear.quadraticBezierTo(218, 147, 213, 138);
          canvas.drawPath(tear, tearPaint);
          break;
      }
    }

    canvas.drawPath(browL, browPaint);
    canvas.drawPath(browR, browPaint);
    canvas.drawPath(mouth, mouthPaint);

    canvas.restore();
  }

  /// Gambar Buah yang Sedang Diinspeksi Sesuai Jenis Buah (Apel, Jeruk, Pisang, Mangga, Tomat)
  void _drawInspectedFruit(Canvas canvas, PakSegarQuality q, String fruitName) {
    switch (fruitName.toLowerCase()) {
      case 'jeruk':
        _drawOrange(canvas, q);
        break;
      case 'pisang':
        _drawBanana(canvas, q);
        break;
      case 'mangga':
        _drawMango(canvas, q);
        break;
      case 'tomat':
        _drawTomato(canvas, q);
        break;
      case 'apel':
      default:
        _drawApple(canvas, q);
        break;
    }
  }

  void _drawApple(Canvas canvas, PakSegarQuality q) {
    Color fruitColor;
    Color leafColor = const Color(0xFF43A047);
    double spotsOpacity = 0.0;

    switch (q) {
      case PakSegarQuality.bagus:
        fruitColor = const Color(0xFFE53935);
        break;
      case PakSegarQuality.cukup:
        fruitColor = const Color(0xFFEF8F3A);
        spotsOpacity = 0.4;
        break;
      case PakSegarQuality.busuk:
        fruitColor = const Color(0xFF6D4C41);
        leafColor = const Color(0xFF8D6E63);
        spotsOpacity = 1.0;
        break;
    }

    final stemPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stemPath = Path();
    stemPath.moveTo(0, -48);
    stemPath.quadraticBezierTo(-4, -75, 14, -85);
    canvas.drawPath(stemPath, stemPaint);

    final leafPaint = Paint()..color = leafColor;
    final leafPath = Path();
    leafPath.moveTo(12, -78);
    leafPath.quadraticBezierTo(40, -98, 58, -72);
    leafPath.quadraticBezierTo(34, -56, 12, -78);
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    final applePaint = Paint()..color = fruitColor;
    final applePath = Path();
    applePath.moveTo(0, -48);
    applePath.cubicTo(-30, -64, -72, -42, -66, 4);
    applePath.cubicTo(-62, 44, -30, 66, 0, 56);
    applePath.cubicTo(30, 66, 62, 44, 66, 4);
    applePath.cubicTo(72, -42, 30, -64, 0, -48);
    applePath.close();
    canvas.drawPath(applePath, applePaint);

    // Kilau
    canvas.save();
    canvas.translate(-30, -12);
    canvas.rotate(20 * pi / 180);
    final glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.28);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 24, height: 44), glintPaint);
    canvas.restore();

    if (spotsOpacity > 0.05) {
      final spotPaint = Paint()..color = const Color(0xFF3E2723).withValues(alpha: spotsOpacity);
      canvas.drawCircle(const Offset(20, 10), 11, spotPaint);
      canvas.drawCircle(const Offset(-18, 26), 8, spotPaint);
      canvas.drawCircle(const Offset(34, -14), 6, spotPaint);
    }
  }

  void _drawOrange(Canvas canvas, PakSegarQuality q) {
    final orangeColor = q == PakSegarQuality.bagus
        ? const Color(0xFFFF9800)
        : (q == PakSegarQuality.cukup ? const Color(0xFFE65100) : const Color(0xFF5D4037));

    final paint = Paint()..color = orangeColor;
    canvas.drawCircle(Offset.zero, 56, paint);

    // Daun kecil
    final leafPaint = Paint()..color = const Color(0xFF388E3C);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, -56), width: 22, height: 12), leafPaint);

    // Kilau
    final glint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-20, -20), width: 20, height: 32), glint);
  }

  void _drawBanana(Canvas canvas, PakSegarQuality q) {
    final bananaColor = q == PakSegarQuality.bagus
        ? const Color(0xFFFFEB3B)
        : (q == PakSegarQuality.cukup ? const Color(0xFFFDD835) : const Color(0xFF4E342E));

    final paint = Paint()
      ..color = bananaColor
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(-45, -35);
    path.quadraticBezierTo(20, -10, 45, 40);
    canvas.drawPath(path, paint);
  }

  void _drawMango(Canvas canvas, PakSegarQuality q) {
    final mangoColor = q == PakSegarQuality.bagus
        ? const Color(0xFFFFB300)
        : (q == PakSegarQuality.cukup ? const Color(0xFFF57C00) : const Color(0xFF4E342E));

    final paint = Paint()..color = mangoColor;
    final path = Path();
    path.moveTo(0, -50);
    path.quadraticBezierTo(45, -30, 40, 25);
    path.quadraticBezierTo(30, 60, -10, 55);
    path.quadraticBezierTo(-45, 40, -35, -15);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawTomato(Canvas canvas, PakSegarQuality q) {
    final tomatoColor = q == PakSegarQuality.bagus
        ? const Color(0xFFF44336)
        : (q == PakSegarQuality.cukup ? const Color(0xFFE53935) : const Color(0xFF5D4037));

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 6), width: 104, height: 92),
      Paint()..color = tomatoColor,
    );

    // Kelopak bintang daun di atas tomat
    final starLeaf = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(const Offset(0, -38), 12, starLeaf);
  }

  void _drawFruitMini(Canvas canvas, Offset pos, Color color, String type) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(0.42, 0.42);

    final stemPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stemPath = Path();
    stemPath.moveTo(0, -48);
    stemPath.quadraticBezierTo(-4, -75, 14, -85);
    canvas.drawPath(stemPath, stemPaint);

    final applePaint = Paint()..color = color;
    final applePath = Path();
    applePath.moveTo(0, -48);
    applePath.cubicTo(-30, -64, -72, -42, -66, 4);
    applePath.cubicTo(-62, 44, -30, 66, 0, 56);
    applePath.cubicTo(30, 66, 62, 44, 66, 4);
    applePath.cubicTo(72, -42, 30, -64, 0, -48);
    applePath.close();
    canvas.drawPath(applePath, applePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PakSegarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.blinkScale != blinkScale ||
        oldDelegate.quality != quality ||
        oldDelegate.targetHand != targetHand ||
        oldDelegate.pose != pose ||
        oldDelegate.fruitType != fruitType ||
        oldDelegate.magnifierWeight != magnifierWeight;
  }
}
