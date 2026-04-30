import 'dart:math' as math;

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  D E F F E C T S  —  Phase 3 공용 효과 모음
//  BackdropFilter / ImageFilter.blur 사용 금지
// ═══════════════════════════════════════════════════════════════

// ── 1. 3D Card Tilt ──────────────────────────────────────────────────────────

/// 터치 시 perspective X/Y rotation 6도, 릴리즈 시 spring back.
class D3DTiltCard extends StatefulWidget {
  final Widget child;
  final double maxTiltDeg;
  final VoidCallback? onTap;

  const D3DTiltCard({
    super.key,
    required this.child,
    this.maxTiltDeg = 6.0,
    this.onTap,
  });

  @override
  State<D3DTiltCard> createState() => _D3DTiltCardState();
}

class _D3DTiltCardState extends State<D3DTiltCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springCtrl;
  late Animation<double> _tiltX;
  late Animation<double> _tiltY;

  double _rawX = 0;
  double _rawY = 0;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _tiltX = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.easeOutBack),
    );
    _tiltY = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d, BoxConstraints box) {
    if (!_pressed) return;
    final dx = d.localPosition.dx / box.maxWidth - 0.5;
    final dy = d.localPosition.dy / box.maxHeight - 0.5;
    final maxRad = widget.maxTiltDeg * math.pi / 180;
    setState(() {
      _rawX = dy * maxRad; // vertical drag → X rotation
      _rawY = -dx * maxRad; // horizontal drag → Y rotation
    });
  }

  void _startTilt(Offset local, BoxConstraints box) {
    _pressed = true;
    final dx = local.dx / box.maxWidth - 0.5;
    final dy = local.dy / box.maxHeight - 0.5;
    final maxRad = widget.maxTiltDeg * math.pi / 180;
    setState(() {
      _rawX = dy * maxRad;
      _rawY = -dx * maxRad;
    });
  }

  void _releaseTilt() {
    _pressed = false;
    _tiltX = Tween<double>(begin: _rawX, end: 0).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.easeOutBack),
    );
    _tiltY = Tween<double>(begin: _rawY, end: 0).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.easeOutBack),
    );
    _springCtrl.forward(from: 0);
    setState(() {
      _rawX = 0;
      _rawY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        return GestureDetector(
          onTapDown: (d) => _startTilt(d.localPosition, box),
          onTapUp: (_) {
            _releaseTilt();
            widget.onTap?.call();
          },
          onTapCancel: _releaseTilt,
          onPanUpdate: (d) => _onPanUpdate(d, box),
          onPanEnd: (_) => _releaseTilt(),
          child: AnimatedBuilder(
            animation: _springCtrl,
            builder: (context, child) {
              final x = _pressed ? _rawX : _tiltX.value;
              final y = _pressed ? _rawY : _tiltY.value;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateX(x)
                  ..rotateY(y),
                child: child,
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ── 2. Shimmer Sweep (좌→우 빛 sweep, 3.2초 주기) ───────────────────────────

class DShimmerSweep extends StatefulWidget {
  final Widget child;
  final double sweepWidth; // fraction 0~1 relative to card
  final double highlightOpacity;
  final Duration period;

  const DShimmerSweep({
    super.key,
    required this.child,
    this.sweepWidth = 0.4,
    this.highlightOpacity = 0.18,
    this.period = const Duration(milliseconds: 3200),
  });

  @override
  State<DShimmerSweep> createState() => _DShimmerSweepState();
}

class _DShimmerSweepState extends State<DShimmerSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                // progress 0→1, sweep from -sweepWidth to 1+sweepWidth
                final pos =
                    _ctrl.value * (1.0 + widget.sweepWidth * 2) - widget.sweepWidth;
                return ClipRect(
                  child: FractionalTranslation(
                    translation: Offset(pos, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white
                                .withValues(alpha: widget.highlightOpacity),
                            Colors.white.withValues(
                                alpha: widget.highlightOpacity * 0.6),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── 3. 다중 펄스 글로우 (Live 배지 — 메인 + 2 액센트 ring) ──────────────────

class DMultiPulseGlow extends StatefulWidget {
  final Color color;
  final Color accentColor;
  final double size;
  final Widget child;

  const DMultiPulseGlow({
    super.key,
    required this.color,
    required this.accentColor,
    required this.size,
    required this.child,
  });

  @override
  State<DMultiPulseGlow> createState() => _DMultiPulseGlowState();
}

class _DMultiPulseGlowState extends State<DMultiPulseGlow>
    with TickerProviderStateMixin {
  late final AnimationController _main;
  late final AnimationController _ring1;
  late final AnimationController _ring2;

  @override
  void initState() {
    super.initState();
    _main = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _ring1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _ring2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _main.dispose();
    _ring1.dispose();
    _ring2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ring 2 — slowest, largest
          AnimatedBuilder(
            animation: _ring2,
            builder: (context, _) {
              final t = _ring2.value;
              final r = widget.size * 0.5 + widget.size * 0.6 * t;
              final opacity = (1 - t) * 0.3;
              return Container(
                width: r * 2,
                height: r * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: opacity),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),
          // ring 1
          AnimatedBuilder(
            animation: _ring1,
            builder: (context, _) {
              final t = _ring1.value;
              final r = widget.size * 0.5 + widget.size * 0.45 * t;
              final opacity = (1 - t) * 0.45;
              return Container(
                width: r * 2,
                height: r * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: opacity),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          // main pulse glow
          AnimatedBuilder(
            animation: _main,
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(
                          alpha: 0.4 + _main.value * 0.4),
                      blurRadius: 12 + _main.value * 12,
                      spreadRadius: _main.value * 4,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

// ── 4. Particle System (별/번개/하트, 18~24개) ──────────────────────────────

enum ParticleShape { star, lightning, heart }

class DParticleEffect extends StatefulWidget {
  final Color color;
  final Color accentColor;
  final int count;
  final bool active;

  const DParticleEffect({
    super.key,
    required this.color,
    required this.accentColor,
    this.count = 20,
    this.active = true,
  });

  @override
  State<DParticleEffect> createState() => _DParticleEffectState();
}

class _DParticleEffectState extends State<DParticleEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.active) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(DParticleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(
        painter: _ParticlePainter(
          progress: _ctrl.value,
          color: widget.color,
          accentColor: widget.accentColor,
          count: widget.count,
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accentColor;
  final int count;

  static final _rng = math.Random(7);

  _ParticlePainter({
    required this.progress,
    required this.color,
    required this.accentColor,
    required this.count,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;

    for (int i = 0; i < count; i++) {
      final phaseOffset = i / count;
      final t = ((progress - phaseOffset + 1.0) % 1.0);
      final fade = math.sin(t * math.pi).clamp(0.0, 1.0);
      if (fade < 0.02) continue;

      final angle = (i / count) * 2 * math.pi + progress * math.pi * 0.5;
      final radius = 60.0 + _rng.nextDouble() * 160.0;
      final x = cx + math.cos(angle) * radius;
      final y = cy + math.sin(angle) * radius * 0.65;
      final pSize = 2.5 + _rng.nextDouble() * 5.0;

      final shapeIdx = i % 3;
      final useAccent = i % 4 == 0;
      final paint = Paint()
        ..color = (useAccent ? accentColor : color)
            .withValues(alpha: fade * 0.8)
        ..style = PaintingStyle.fill;

      switch (shapeIdx) {
        case 0:
          _drawStar(canvas, Offset(x, y), pSize, paint);
        case 1:
          _drawLightning(canvas, Offset(x, y), pSize, paint);
        default:
          _drawHeart(canvas, Offset(x, y), pSize * 0.9, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset c, double s, Paint p) {
    final path = Path();
    for (int j = 0; j < 4; j++) {
      final outerA = j * math.pi / 2 - math.pi / 4;
      final innerA = outerA + math.pi / 4;
      final ox = c.dx + math.cos(outerA) * s;
      final oy = c.dy + math.sin(outerA) * s;
      final ix = c.dx + math.cos(innerA) * s * 0.36;
      final iy = c.dy + math.sin(innerA) * s * 0.36;
      if (j == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawLightning(Canvas canvas, Offset c, double s, Paint p) {
    final path = Path()
      ..moveTo(c.dx + s * 0.2, c.dy - s)
      ..lineTo(c.dx - s * 0.1, c.dy - s * 0.05)
      ..lineTo(c.dx + s * 0.3, c.dy - s * 0.05)
      ..lineTo(c.dx - s * 0.2, c.dy + s)
      ..lineTo(c.dx + s * 0.1, c.dy + s * 0.05)
      ..lineTo(c.dx - s * 0.3, c.dy + s * 0.05)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawHeart(Canvas canvas, Offset c, double s, Paint p) {
    final path = Path();
    path.moveTo(c.dx, c.dy + s * 0.9);
    path.cubicTo(
      c.dx - s * 1.5, c.dy + s * 0.2,
      c.dx - s * 1.5, c.dy - s * 0.9,
      c.dx, c.dy - s * 0.3,
    );
    path.cubicTo(
      c.dx + s * 1.5, c.dy - s * 0.9,
      c.dx + s * 1.5, c.dy + s * 0.2,
      c.dx, c.dy + s * 0.9,
    );
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ── 5. Parallax Scroll helper ────────────────────────────────────────────────

/// ScrollController로 parallax offset을 계산해 child를 이동시킨다.
/// child를 parent Stack 안에 Positioned로 배치해 사용.
class DParallaxLayer extends StatelessWidget {
  final ScrollController scrollController;
  final Widget child;
  final double factor; // 0.3 = 30% of scroll distance

  const DParallaxLayer({
    super.key,
    required this.scrollController,
    required this.child,
    this.factor = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        final offset = scrollController.hasClients
            ? scrollController.offset * factor
            : 0.0;
        return Transform.translate(
          offset: Offset(0, -offset),
          child: child,
        );
      },
    );
  }
}

// ── 6. 공통 Diamond Grid Painter ─────────────────────────────────────────────

class DDiamondGridPainter extends CustomPainter {
  final Color color;
  final double step;

  const DDiamondGridPainter(this.color, {this.step = 44.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..lineTo(x, y + step / 2)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DDiamondGridPainter old) =>
      old.color != color || old.step != step;
}

// ── 7. Scanline Painter (공통) ─────────────────────────────────────────────

class DScanlinePainter extends CustomPainter {
  final double opacity;
  const DScanlinePainter({this.opacity = 0.015});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant DScanlinePainter old) =>
      old.opacity != opacity;
}

// ── 8. 폭발형 Particle (출정/예측 적중/리워드 교환) — 원샷 ─────────────────

class DExplosionParticles extends StatefulWidget {
  final Color color;
  final Color accentColor;
  final int count;

  const DExplosionParticles({
    super.key,
    required this.color,
    required this.accentColor,
    this.count = 24,
  });

  @override
  State<DExplosionParticles> createState() => _DExplosionParticlesState();
}

class _DExplosionParticlesState extends State<DExplosionParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(
        painter: _ExplosionPainter(
          progress: _ctrl.value,
          color: widget.color,
          accentColor: widget.accentColor,
          count: widget.count,
        ),
      ),
    );
  }
}

class _ExplosionPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accentColor;
  final int count;

  static final _rng = math.Random(13);

  _ExplosionPainter({
    required this.progress,
    required this.color,
    required this.accentColor,
    required this.count,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.40;

    for (int i = 0; i < count; i++) {
      final phaseOffset = i / count;
      final t = ((progress - phaseOffset + 1.0) % 1.0);
      final scaleT = Curves.easeOutCubic.transform(t);
      final fade = math.sin(t * math.pi).clamp(0.0, 1.0);
      if (fade < 0.02) continue;

      final angle = (i / count) * 2 * math.pi;
      final spread = 40.0 + _rng.nextDouble() * 140.0;
      final x = cx + math.cos(angle) * spread * scaleT;
      final y = cy + math.sin(angle) * spread * scaleT * 0.6;
      final pSize = 3.0 + _rng.nextDouble() * 6.0;

      final useAccent = i % 3 == 0;
      final paint = Paint()
        ..color = (useAccent ? accentColor : color)
            .withValues(alpha: fade * 0.85)
        ..style = PaintingStyle.fill;

      // alternate star & lightning
      if (i % 2 == 0) {
        _drawStar(canvas, Offset(x, y), pSize, paint);
      } else {
        _drawLightning(canvas, Offset(x, y), pSize, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset c, double s, Paint p) {
    final path = Path();
    for (int j = 0; j < 4; j++) {
      final outerA = j * math.pi / 2 - math.pi / 4;
      final innerA = outerA + math.pi / 4;
      final ox = c.dx + math.cos(outerA) * s;
      final oy = c.dy + math.sin(outerA) * s;
      final ix = c.dx + math.cos(innerA) * s * 0.36;
      final iy = c.dy + math.sin(innerA) * s * 0.36;
      if (j == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawLightning(Canvas canvas, Offset c, double s, Paint p) {
    final path = Path()
      ..moveTo(c.dx + s * 0.2, c.dy - s)
      ..lineTo(c.dx - s * 0.1, c.dy - s * 0.05)
      ..lineTo(c.dx + s * 0.3, c.dy - s * 0.05)
      ..lineTo(c.dx - s * 0.2, c.dy + s)
      ..lineTo(c.dx + s * 0.1, c.dy + s * 0.05)
      ..lineTo(c.dx - s * 0.3, c.dy + s * 0.05)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ExplosionPainter old) => old.progress != progress;
}
