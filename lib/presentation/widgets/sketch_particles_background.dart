import 'dart:math';
import 'package:flutter/material.dart';

/// Partikel individu untuk simulasi sketch.js
class _Particle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double phase;
  final double alpha;
  final double drift;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.alpha,
    required this.drift,
  });
}

/// Canvas widget bergaya sketch.js / creative coding
/// Menggambar partikel organik melayang dengan osilasi gelombang sinus di GPU
class SketchParticlesBackground extends StatefulWidget {
  final Widget? child;
  final Color particleColor;
  final int particleCount;
  final bool enableConnections;
  final double maxDistance;

  const SketchParticlesBackground({
    super.key,
    this.child,
    this.particleColor = Colors.white,
    this.particleCount = 28,
    this.enableConnections = true,
    this.maxDistance = 55.0,
  });

  @override
  State<SketchParticlesBackground> createState() => _SketchParticlesBackgroundState();
}

class _SketchParticlesBackgroundState extends State<SketchParticlesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();

    // Inisialisasi pool partikel tetap (mencegah alokasi memori di frame loop)
    _particles = List.generate(widget.particleCount, (index) {
      return _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: 1.5 + _random.nextDouble() * 3.5,
        speed: 0.2 + _random.nextDouble() * 0.4,
        phase: _random.nextDouble() * 2 * pi,
        alpha: 0.15 + _random.nextDouble() * 0.45,
        drift: (_random.nextDouble() - 0.5) * 0.08,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SketchParticlesPainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.particleColor,
            enableConnections: widget.enableConnections,
            maxDistance: widget.maxDistance,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SketchParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;
  final bool enableConnections;
  final double maxDistance;

  final Paint _particlePaint = Paint()..isAntiAlias = true;
  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.8;

  _SketchParticlesPainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.enableConnections,
    required this.maxDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final positions = <Offset>[];

    // 1. Hitung posisi koordinat setiap partikel dengan gelombang osilasi sinus
    for (final p in particles) {
      final curY = ((p.y - progress * p.speed) % 1.0 + 1.0) % 1.0;
      final curX = ((p.x + sin(progress * 2 * pi + p.phase) * 0.05 + p.drift * progress) % 1.0 + 1.0) % 1.0;

      final px = curX * size.width;
      final py = curY * size.height;
      final pos = Offset(px, py);
      positions.add(pos);

      // Gambar partikel
      _particlePaint.color = color.withValues(alpha: p.alpha);
      canvas.drawCircle(pos, p.radius, _particlePaint);
    }

    // 2. Hubungkan partikel yang berdekatan dengan garis jaring halus (Constellation Effect ala sketch.js)
    if (enableConnections) {
      for (int i = 0; i < positions.length; i++) {
        for (int j = i + 1; j < positions.length; j++) {
          final p1 = positions[i];
          final p2 = positions[j];
          final dx = p1.dx - p2.dx;
          final dy = p1.dy - p2.dy;
          final dist = sqrt(dx * dx + dy * dy);

          if (dist < maxDistance) {
            final lineAlpha = (1.0 - (dist / maxDistance)) * 0.18;
            _linePaint.color = color.withValues(alpha: lineAlpha);
            canvas.drawLine(p1, p2, _linePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SketchParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
