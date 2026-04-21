import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class TiltGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double opacity;
  final double maxTilt;
  final VoidCallback? onTap;

  const TiltGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.opacity = 0.18,
    this.maxTilt = 0.08,
    this.onTap,
  });

  @override
  State<TiltGlassCard> createState() => _TiltGlassCardState();
}

class _TiltGlassCardState extends State<TiltGlassCard> {
  double dx = 0;
  double dy = 0;

  void _reset() {
    setState(() {
      dx = 0;
      dy = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (d) {
        setState(() {
          dx = (dx + d.delta.dx * 0.002).clamp(-widget.maxTilt, widget.maxTilt);
          dy = (dy - d.delta.dy * 0.002).clamp(-widget.maxTilt, widget.maxTilt);
        });
      },
      onPanEnd: (_) => _reset(),
      onPanCancel: _reset,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(dy)
          ..rotateY(dx),
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(widget.opacity),
                borderRadius: widget.borderRadius,
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.14),
                  width: 1.15,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.05),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}