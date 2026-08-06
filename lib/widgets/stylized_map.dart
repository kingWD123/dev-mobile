import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StylizedMap extends StatelessWidget {
  final double height;
  final double routeProgress;
  final bool showCar;
  final BorderRadius? borderRadius;

  const StylizedMap({
    super.key,
    this.height = 180,
    this.routeProgress = 1,
    this.showCar = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _MapPainter(isDark: isDark, progress: routeProgress, showCar: showCar),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final bool isDark;
  final double progress;
  final bool showCar;

  _MapPainter({required this.isDark, required this.progress, required this.showCar});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = isDark ? const Color(0xFF16211D) : const Color(0xFFE7F1EC);
    canvas.drawRect(Offset.zero & size, bg);

    final dot = Paint()..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06);
    const step = 20.0;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.1, dot);
      }
    }

    final streetPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.07 : 0.055)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10, size.height * 0.22), Offset(size.width + 10, size.height * 0.14), streetPaint);
    canvas.drawLine(Offset(-10, size.height * 0.78), Offset(size.width + 10, size.height * 0.86), streetPaint);
    canvas.drawLine(Offset(size.width * 0.2, -10), Offset(size.width * 0.3, size.height + 10), streetPaint);
    canvas.drawLine(Offset(size.width * 0.74, -10), Offset(size.width * 0.64, size.height + 10), streetPaint);

    final start = Offset(size.width * 0.13, size.height * 0.84);
    final end = Offset(size.width * 0.87, size.height * 0.16);
    final c1 = Offset(size.width * 0.32, size.height * 0.92);
    final c2 = Offset(size.width * 0.58, size.height * 0.04);

    final routePath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);

    final routePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.85)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, routePath, routePaint);

    _drawOrigin(canvas, start);
    _drawIcon(canvas, end - const Offset(0, 11), Icons.location_on, AppColors.primary, 26);

    if (showCar) {
      final t = progress.clamp(0.0, 1.0);
      final carPos = _cubicPoint(start, c1, c2, end, t);
      final tangent = _cubicTangentAngle(start, c1, c2, end, t);
      canvas.drawCircle(carPos, 15, Paint()..color = AppColors.primary.withValues(alpha: 0.16));
      canvas.drawCircle(carPos, 10, Paint()..color = Colors.white);
      canvas.save();
      canvas.translate(carPos.dx, carPos.dy);
      canvas.rotate(tangent + math.pi / 2);
      canvas.translate(-carPos.dx, -carPos.dy);
      _drawIcon(canvas, carPos, Icons.navigation, AppColors.primary, 16);
      canvas.restore();
    }
  }

  void _drawOrigin(Canvas canvas, Offset pos) {
    canvas.drawCircle(pos, 8, Paint()..color = Colors.white);
    canvas.drawCircle(pos, 8, Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);
    canvas.drawCircle(pos, 3.2, Paint()..color = AppColors.primary);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      const dashLen = 8.0, gapLen = 6.0;
      while (distance < metric.length) {
        final len = math.min(dashLen, metric.length - distance);
        canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        distance += dashLen + gapLen;
      }
    }
  }

  void _drawIcon(Canvas canvas, Offset center, IconData icon, Color color, double size) {
    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontFamily: icon.fontFamily, package: icon.fontPackage, fontSize: size, color: color),
      )
      ..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  Offset _cubicPoint(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    final x = u * u * u * p0.dx + 3 * u * u * t * p1.dx + 3 * u * t * t * p2.dx + t * t * t * p3.dx;
    final y = u * u * u * p0.dy + 3 * u * u * t * p1.dy + 3 * u * t * t * p2.dy + t * t * t * p3.dy;
    return Offset(x, y);
  }

  double _cubicTangentAngle(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    final dx = 3 * u * u * (p1.dx - p0.dx) + 6 * u * t * (p2.dx - p1.dx) + 3 * t * t * (p3.dx - p2.dx);
    final dy = 3 * u * u * (p1.dy - p0.dy) + 6 * u * t * (p2.dy - p1.dy) + 3 * t * t * (p3.dy - p2.dy);
    return math.atan2(dy, dx);
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.progress != progress || old.isDark != isDark || old.showCar != showCar;
}
