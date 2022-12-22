  import 'dart:math';
  import 'package:flutter/material.dart';

  /// Returns a [LinearGradient] with random colors.
  LinearGradient getRandomGradient() {
    const List gradients = [
      [0xFF4A00E0, 0xFF8E2DE2],
      [0xFF4A00E0, 0xFF62BCFA],
      [0xFFCC2B5E, 0xFF753A88],
      [0xFF4E54C8, 0xFF8F94FB],
      [0xFFF953C6, 0xFFB91D73],
      [0xFF41295A, 0xFF2F0743],
      [0xFF4776E6, 0xFF8E54E9],
      [0xFF5433FF, 0xFF20BDFF],
    ];

    var gradientColors = gradients
        .map(
            (colorCodes) => <Color>[Color(colorCodes[0]), Color(colorCodes[1])])
        .toList();

    return LinearGradient(
      begin: FractionalOffset(0.0, 0.0),
      end: FractionalOffset(2.0, 0.0),
      stops: [0.0, 0.5],
      colors: gradientColors[Random().nextInt(8)],
    );
  }