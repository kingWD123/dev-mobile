import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A small hand-drawn, original flat-style car illustration — adds warmth to
/// hero and empty-state moments without pulling in external image assets.
class CarIllustration extends StatelessWidget {
  final double width;
  final Color? bodyColor;

  const CarIllustration({super.key, this.width = 160, this.bodyColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.55,
      child: CustomPaint(painter: _CarPainter(bodyColor: bodyColor ?? AppColors.primary)),
    );
  }
}

class _CarPainter extends CustomPainter {
  final Color bodyColor;
  _CarPainter({required this.bodyColor});

  static const double _vbWidth = 200;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _vbWidth;
    canvas.save();
    canvas.scale(scale);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 92), width: 150, height: 14),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );

    final body = Path()
      ..moveTo(14, 78)
      ..lineTo(14, 62)
      ..quadraticBezierTo(16, 50, 32, 48)
      ..lineTo(48, 48)
      ..quadraticBezierTo(58, 26, 78, 22)
      ..lineTo(126, 22)
      ..quadraticBezierTo(146, 26, 154, 48)
      ..lineTo(168, 48)
      ..quadraticBezierTo(186, 50, 186, 64)
      ..lineTo(186, 78)
      ..quadraticBezierTo(186, 84, 180, 84)
      ..lineTo(20, 84)
      ..quadraticBezierTo(14, 84, 14, 78)
      ..close();
    canvas.drawPath(body, Paint()..color = bodyColor);

    final window = Path()
      ..moveTo(52, 47)
      ..quadraticBezierTo(60, 30, 78, 27)
      ..lineTo(122, 27)
      ..quadraticBezierTo(140, 30, 150, 47)
      ..close();
    canvas.drawPath(window, Paint()..color = Colors.white.withValues(alpha: 0.88));
    canvas.drawRect(const Rect.fromLTWH(99, 27, 2.5, 20), Paint()..color = bodyColor.withValues(alpha: 0.5));

    canvas.drawLine(
      const Offset(100, 48),
      const Offset(100, 82),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..strokeWidth = 1.5,
    );

    canvas.drawCircle(const Offset(180, 60), 4, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(const Offset(20, 60), 4, Paint()..color = Colors.black.withValues(alpha: 0.25));

    _drawWheel(canvas, const Offset(52, 84));
    _drawWheel(canvas, const Offset(150, 84));

    canvas.restore();
  }

  void _drawWheel(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 15, Paint()..color = const Color(0xFF23262A));
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFF5A5F66));
  }

  @override
  bool shouldRepaint(covariant _CarPainter oldDelegate) => oldDelegate.bodyColor != bodyColor;
}
