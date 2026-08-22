import 'package:flutter/material.dart';

const _palette = [
  Color(0xFF0E8C6F),
  Color(0xFFC97A3D),
  Color(0xFF3E7CB1),
  Color(0xFF8B6BB0),
  Color(0xFFB2555F),
];

class DriverAvatar extends StatelessWidget {
  final String name;
  final double size;

  const DriverAvatar({super.key, required this.name, this.size = 48});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Color get _color => _palette[name.hashCode.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _color.withValues(alpha: 0.16),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: _color,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.36,
          ),
        ),
      ),
    );
  }
}
