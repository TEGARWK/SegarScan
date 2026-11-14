import 'dart:math';
import 'package:flutter/material.dart';

/// Widget animasi maskot bergaya Lottie / 2D Puppet Animation (Disney Squash & Stretch).
/// Menghadirkan:
/// - Organic floating & breathing (idle sine-wave)
/// - Squash & Stretch alami saat mengambang
/// - Subtle sway tilt rotasi
/// - Laser scanner beam aktif yang memindai buah bolak-balik
/// - Gelombang radar target AI pendar (holographic scan circle)
/// - Gelembung buah melayang pendamping (🍎 / 🍊)
/// - Dynamic responsive floor shadow
/// - Interactive tap reaction dengan speech bubble "Siap Sortir! 🥑"
class AnimatedMascot extends StatefulWidget {
  final String imagePath;
  final double size;

  const AnimatedMascot({
    super.key,
    required this.imagePath,
    this.size = 105,
  });

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _scanLaserController;
  late final AnimationController _radarController;
  late final AnimationController _sparkleController;
  late final AnimationController _tapBounceController;

  late final Animation<double> _bobAnimation;
  late final Animation<double> _swayAnimation;
  late final Animation<double> _squashXAnimation;
  late final Animation<double> _squashYAnimation;
  late final Animation<double> _laserPositionAnimation;
  late final Animation<double> _radarRadiusAnimation;
  late final Animation<double> _sparklePulseAnimation;

  bool _showSpeechBubble = false;

  @override
  void initState() {
    super.initState();

    // 1. Idle Bobbing & Squash-and-Stretch (2.6 detik per siklus bolak-balik)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _bobAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    _swayAnimation = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    // Squash & Stretch: melebar saat di bawah, meninggi saat melayang di atas
    _squashXAnimation = Tween<double>(begin: 0.98, end: 1.025).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    _squashYAnimation = Tween<double>(begin: 1.025, end: 0.98).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOutSine),
    );

    // 2. Laser Scanner Vertical Sweep (1.8 detik bolak-balik menyapu buah)
    _scanLaserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserPositionAnimation = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(parent: _scanLaserController, curve: Curves.easeInOut),
    );

    // 3. Radar Pulse AI expanding ripple
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _radarRadiusAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOut),
    );

    // 4. Sparkle Twinkle
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _sparklePulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    // 5. Tap Elastic Bounce
    _tapBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _scanLaserController.dispose();
    _radarController.dispose();
    _sparkleController.dispose();
    _tapBounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapBounceController.forward(from: 0.0);
    setState(() {
      _showSpeechBubble = true;
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _showSpeechBubble = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _idleController,
          _scanLaserController,
          _radarController,
          _sparkleController,
          _tapBounceController,
        ]),
        builder: (context, child) {
          final tapBounce = sin(_tapBounceController.value * pi) * 0.15;
          final scaleX = _squashXAnimation.value + tapBounce;
          final scaleY = _squashYAnimation.value + tapBounce;

          return SizedBox(
            width: widget.size + 16,
            height: widget.size + 24,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Dynamic Floor Shadow (meregang saat turun, memudar saat naik)
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: (widget.size * 0.65) * (_bobAnimation.value > 0 ? 1.08 : 0.92),
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(widget.size * 0.65, 10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.22 - (_bobAnimation.value + 6.0) * 0.012,
                          ),
                          blurRadius: 10 + (_bobAnimation.value + 6.0),
                          spreadRadius: 1.5,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Karakter Utama dengan Transform Bobbing, Sway & Squash-and-Stretch
                Positioned(
                  top: 12 + _bobAnimation.value,
                  child: Transform.rotate(
                    angle: _swayAnimation.value,
                    child: Transform.scale(
                      scaleX: scaleX,
                      scaleY: scaleY,
                      child: Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.45),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.25),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Gambar Maskot
                              Image.asset(
                                widget.imagePath,
                                fit: BoxFit.cover,
                              ),

                              // Sinar Scanner Hologram Radial Glow
                              CustomPaint(
                                painter: _ScanHologramPainter(
                                  laserPos: _laserPositionAnimation.value,
                                  radarRadius: _radarRadiusAnimation.value,
                                ),
                              ),

                              // Glass Sheen Highlight melintang diagonal halus
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: const Alignment(-1.0, -1.0),
                                      end: const Alignment(1.0, 1.0),
                                      colors: [
                                        Colors.white.withValues(alpha: 0.18),
                                        Colors.transparent,
                                        Colors.transparent,
                                        Colors.white.withValues(alpha: 0.08),
                                      ],
                                      stops: const [0.0, 0.35, 0.7, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Mini Floating Companion Bubble (Hologram Fruit Target 🥑)
                Positioned(
                  top: 0 - _bobAnimation.value * 0.7, // Berlawanan arah bobbing
                  left: -2,
                  child: Transform.rotate(
                    angle: -_swayAnimation.value * 1.5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF43A047).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        '🍎',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),

                // 4. Sparkle Star Twinkle (Pojok Kiri Bawah)
                Positioned(
                  bottom: 18 + _bobAnimation.value,
                  left: -4,
                  child: Opacity(
                    opacity: _sparklePulseAnimation.value,
                    child: Transform.scale(
                      scale: _sparklePulseAnimation.value,
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFFFD54F),
                        size: 16,
                      ),
                    ),
                  ),
                ),

                // 5. Badge Indikator "AI LIVE" Pendar
                Positioned(
                  top: 6 + _bobAnimation.value,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00C853)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(
                            alpha: _sparklePulseAnimation.value * 0.7,
                          ),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.radar_rounded,
                          size: 9,
                          color: Color(0xFF1B5E20),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'AI SCAN',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1B5E20),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Speech Bubble Interaktif saat Diklik ("Siap Sortir! 🥑")
                if (_showSpeechBubble)
                  Positioned(
                    top: -24,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.elasticOut,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Siap Sortir! 🥑',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// CustomPainter untuk menghasilkan efek scan laser line dan radar rings khas Lottie / sci-fi AI
class _ScanHologramPainter extends CustomPainter {
  final double laserPos; // 0.0 sampai 1.0
  final double radarRadius; // 0.0 sampai 1.0

  _ScanHologramPainter({
    required this.laserPos,
    required this.radarRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Garis Laser Menyapu (Laser Beam Sweep)
    final yPos = size.height * laserPos;

    // Laser Glow Trail
    final trailRect = Rect.fromLTRB(0, yPos - 12, size.width, yPos);
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF00E676).withValues(alpha: 0.22),
        ],
      ).createShader(trailRect);
    canvas.drawRect(trailRect, trailPaint);

    // Garis Laser Inti (Sharp Bright Laser)
    final linePaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), linePaint);

    // Titik sensor di ujung garis laser
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.15, yPos), 2.2, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.85, yPos), 2.2, dotPaint);

    // 2. Lingkaran Radar Target di Pusat Pemeriksaan Buah
    final centerOffset = Offset(size.width * 0.55, size.height * 0.55);
    final maxRadius = size.width * 0.35;
    final currentRadius = maxRadius * radarRadius;
    final ringAlpha = (1.0 - radarRadius).clamp(0.0, 1.0) * 0.45;

    final radarPaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: ringAlpha)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(centerOffset, currentRadius, radarPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanHologramPainter oldDelegate) {
    return oldDelegate.laserPos != laserPos ||
        oldDelegate.radarRadius != radarRadius;
  }
}
