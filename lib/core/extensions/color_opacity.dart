import 'package:flutter/material.dart';

extension SafeOpacity on Color {
  Color op(double opacity) {
    return withAlpha((opacity.clamp(0, 1) * 255).round());
  }
}
