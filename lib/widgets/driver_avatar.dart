import 'package:flutter/material.dart';
import '../models/ride_models.dart';

class DriverAvatar extends StatelessWidget {
  final Driver driver;
  final double size;

  const DriverAvatar({super.key, required this.driver, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: driver.color.withValues(alpha: 0.16),
      ),
      child: Center(
        child: Text(
          driver.initials,
          style: TextStyle(
            color: driver.color,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.36,
          ),
        ),
      ),
    );
  }
}
