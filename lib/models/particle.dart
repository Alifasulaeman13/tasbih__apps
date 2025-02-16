import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double dx;
  double dy;
  Color color;
  double size;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
    this.opacity = 1.0,
  });
}
