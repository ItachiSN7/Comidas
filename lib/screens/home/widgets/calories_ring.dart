import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CaloriesRing extends StatefulWidget {
  final double consumed;
  final double target;
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;

  const CaloriesRing({
    super.key,
    required this.consumed,
    required this.target,
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatProgress,
  });

  @override
  State<CaloriesRing> createState() => _CaloriesRingState();
}

class _CaloriesRingState extends State<CaloriesRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.target > 0
        ? (widget.consumed / widget.target).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (widget.target - widget.consumed).clamp(0, double.infinity);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Background track
              CustomPaint(
                size: const Size(200, 200),
                painter: _RingPainter(
                  progress: 1.0,
                  color: AppColors.primary.withOpacity(0.08),
                  strokeWidth: 14,
                  startAngle: -math.pi / 2,
                ),
              ),
              // Main ring (calories)
              CustomPaint(
                size: const Size(200, 200),
                painter: _RingPainter(
                  progress: progress * _animation.value,
                  color: AppColors.primary,
                  strokeWidth: 14,
                  startAngle: -math.pi / 2,
                  gradientColors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              // Inner macros rings
              CustomPaint(
                size: const Size(165, 165),
                painter: _RingPainter(
                  progress: widget.proteinProgress * _animation.value,
                  color: AppColors.proteinColor,
                  strokeWidth: 6,
                  startAngle: -math.pi / 2,
                ),
              ),
              CustomPaint(
                size: const Size(148, 148),
                painter: _RingPainter(
                  progress: widget.carbsProgress * _animation.value,
                  color: AppColors.carbsColor,
                  strokeWidth: 6,
                  startAngle: -math.pi / 2,
                ),
              ),
              CustomPaint(
                size: const Size(131, 131),
                painter: _RingPainter(
                  progress: widget.fatProgress * _animation.value,
                  color: AppColors.fatColor,
                  strokeWidth: 6,
                  startAngle: -math.pi / 2,
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.consumed.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'kcal consumidas',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${remaining.toInt()} restantes',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final List<Color>? gradientColors;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradientColors != null && gradientColors!.length >= 2) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      bgPaint.shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * math.pi * progress,
        colors: gradientColors!,
      ).createShader(rect);
    } else {
      bgPaint.color = color;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      bgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
