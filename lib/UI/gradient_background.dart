import 'package:flutter/material.dart';

class GradientBackground {
  static LinearGradient getGradient(Color color) {
    return LinearGradient(
      // Where the linear gradient begins and ends
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      // Add one stop for each color. Stops should increase from 0 to 1
      stops: [0.3, 0.5, 0.7, 0.9],
      colors: getColorList(color),
    );
  }
}

List<Color> getColorList(Color color) {
  if (color is MaterialColor) {
    return [
      color[300]!,
      color[600]!,
      color[700]!,
      color[900]!,
    ];
  } else {
    return List<Color>.filled(4, color);
  }
}
