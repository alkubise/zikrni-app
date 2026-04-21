import 'package:flutter/material.dart';

class BeadWidget extends StatelessWidget {
  final int count;

  const BeadWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFF22D3EE),
            Color(0xFF020617),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.8),
            blurRadius: 30,
          )
        ],
      ),
      child: Center(
        child: Text(
          "$count",
          style: TextStyle(
            fontSize: 45,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}