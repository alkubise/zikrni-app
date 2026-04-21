import 'package:flutter/material.dart';

class AppLayout {
  final BuildContext context;
  final Size size;
  final EdgeInsets padding;

  AppLayout(this.context)
      : size = MediaQuery.of(context).size,
        padding = MediaQuery.of(context).padding;

  double get width => size.width;
  double get height => size.height;

  bool get isSmallPhone => width < 360;
  bool get isPhone => width < 600;
  bool get isTablet => width >= 600;

  double scale(double value) {
    final baseWidth = isTablet ? 800.0 : 390.0;
    final factor = (width / baseWidth).clamp(0.82, 1.22);
    return value * factor;
  }

  double topSafe(double extra) => padding.top + extra;
  double bottomSafe(double extra) => padding.bottom + extra;

  EdgeInsets screenPadding({
    double horizontal = 20,
    double top = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.fromLTRB(
      scale(horizontal),
      padding.top + scale(top),
      scale(horizontal),
      padding.bottom + scale(bottom),
    );
  }
}
