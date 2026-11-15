import 'dart:math';

// flutter_deck is built on package:flutter/material.dart, so the app has to
// use the same library rather than package:material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:passkeys_presentation/shared/brand.dart';
import 'package:passkeys_presentation/supabase_schema.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The number of people with a passkey in the project, updated live, with a
/// burst of confetti above the number whenever someone creates their first one.
class PasskeyCounter extends StatefulWidget {
  const PasskeyCounter({super.key});

  @override
  State<PasskeyCounter> createState() => _PasskeyCounterState();
}

class _PasskeyCounterState extends State<PasskeyCounter> {
  final _stats = Supabase.instance.client
      .table(PasskeyStats.table)
      .stream(primaryKey: [PasskeyStats.id]);
  final _confetti = GlobalKey<ConfettiBurstState>();
  int? _count;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stats,
      builder: (context, snapshot) {
        final rows = snapshot.data;
        final count = rows == null || rows.isEmpty
            ? null
            : rows.first.passkeyUsers;
        if (count != null && count != _count) {
          final previous = _count;
          _count = count;
          if (previous != null && count > previous) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _confetti.currentState?.burst(),
            );
          }
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConfettiBurst(
              key: _confetti,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                  ),
                  child: child,
                ),
                child: Text(
                  count?.toString() ?? '-',
                  key: ValueKey(count),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Brand.green,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Text(
                count == 1
                    ? 'person has created a passkey'
                    : 'people have created a passkey',
                style: const TextStyle(fontSize: 30, color: Brand.mutedText),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Shoots confetti upwards from the top of [child] when [burst] is called.
/// The confetti only covers the area above the child.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    required this.child,
    this.height = 260,
    this.particleCount = 60,
    super.key,
  });

  final Widget child;

  /// How far above the child the confetti can fly.
  final double height;
  final int particleCount;

  @override
  State<ConfettiBurst> createState() => ConfettiBurstState();
}

class ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const _colors = [
    Brand.green,
    Color(0xFFFFC857),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFA78BFA),
    Colors.white,
  ];

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  final _random = Random();
  var _particles = <_Particle>[];

  void burst() {
    _particles = [
      for (var i = 0; i < widget.particleCount; i++)
        _Particle(
          // Mostly upwards, spread up to 40 degrees to each side.
          angle: -pi / 2 + (_random.nextDouble() - 0.5) * pi * 0.45,
          speed: 0.55 + _random.nextDouble() * 0.45,
          spin: (_random.nextDouble() - 0.5) * 16,
          size: 6 + _random.nextDouble() * 8,
          color: _colors[_random.nextInt(_colors.length)],
          startX: (_random.nextDouble() - 0.5) * 0.6,
        ),
    ];
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          left: -widget.height / 2,
          right: -widget.height / 2,
          // The confetti area ends where the child starts.
          top: -widget.height,
          height: widget.height,
          child: IgnorePointer(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.isAnimating ? _controller.value : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.size,
    required this.color,
    required this.startX,
  });

  final double angle;
  final double speed;
  final double spin;
  final double size;
  final Color color;

  /// Horizontal start offset as a fraction of the emitter width.
  final double startX;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    // The emitter sits at the bottom center, where the number's top is.
    final origin = Offset(size.width / 2, size.height);
    final t = progress;
    final opacity = (1 - t * t).clamp(0.0, 1.0);
    for (final particle in particles) {
      // A ballistic path: launched up, pulled back down by gravity.
      final distance = particle.speed * size.height * 1.9;
      final dx = cos(particle.angle) * distance * t;
      final dy = sin(particle.angle) * distance * t + size.height * 1.4 * t * t;
      final position =
          origin + Offset(particle.startX * size.width * 0.3 + dx, dy);
      canvas
        ..save()
        ..translate(position.dx, position.dy)
        ..rotate(particle.spin * t);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.5,
        ),
        Paint()..color = particle.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      !identical(oldDelegate.particles, particles);
}
