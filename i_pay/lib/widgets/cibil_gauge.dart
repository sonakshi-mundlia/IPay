import 'dart:math';
import 'package:flutter/material.dart';

class CibilGauge extends StatelessWidget {
  final int score;

  const CibilGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final normalized = ((score - 300) / 600).clamp(0.0, 1.0);

    Color needleColor;
    if (score < 580) {
      needleColor = Colors.red;
    } else if (score < 650) {
      needleColor = Colors.orange;
    } else if (score < 720) {
      needleColor = Colors.yellow;
    } else if (score < 800) {
      needleColor = Colors.lightGreen;
    } else {
      needleColor = Colors.green;
    }

    return CustomPaint(
      size: const Size(260, 260),
      painter: _GaugePainter(normalized, needleColor),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color needleColor;

  _GaugePainter(this.value, this.needleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    // Draw segments
    final segments = [
      _segment(300, 579, Colors.red),
      _segment(580, 649, Colors.orange),
      _segment(650, 719, Colors.yellow),
      _segment(720, 799, Colors.lightGreen),
      _segment(800, 900, Colors.green),
    ];

    for (final seg in segments) {
      final start = (seg.start - 300) / 600 * pi;
      final sweep = (seg.end - seg.start) / 600 * pi;
      arcPaint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi + start,
        sweep,
        false,
        arcPaint,
      );
    }

    // Needle
    final angle = pi + value * pi;
    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 4;

    canvas.drawLine(
      center,
      Offset(
        center.dx + cos(angle) * (radius - 20),
        center.dy + sin(angle) * (radius - 20),
      ),
      needlePaint,
    );

    canvas.drawCircle(center, 6, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(_) => true;
}

class _segment {
  final int start;
  final int end;
  final Color color;

  _segment(this.start, this.end, this.color);
}
