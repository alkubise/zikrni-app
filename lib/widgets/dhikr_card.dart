import 'package:flutter/material.dart';

class DhikrCard extends StatefulWidget {
  final String title;
  final int count;
  final VoidCallback? onComplete;

  const DhikrCard({
    super.key,
    required this.title,
    required this.count,
    this.onComplete,
  });

  @override
  State<DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<DhikrCard> {
  int remaining = 0;

  @override
  void initState() {
    super.initState();
    remaining = widget.count;
  }

  void _increment() {
    if (remaining > 0) {
      setState(() {
        remaining--;
      });
      if (remaining == 0 && widget.onComplete != null) {
        widget.onComplete!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: remaining == 0 
              ? Colors.green.withOpacity(0.1) 
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: remaining == 0 
                ? Colors.green.withOpacity(0.3) 
                : Colors.white.withOpacity(0.1)
          ),
        ),
        child: InkWell(
          onTap: _increment,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "المتبقي: $remaining",
                    style: TextStyle(
                      color: remaining == 0 ? Colors.green : Colors.white70,
                      fontFamily: "Cairo",
                    ),
                  ),
                  if (remaining == 0)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${widget.count}",
                        style: const TextStyle(color: Color(0xFFD4AF37)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 1 - (remaining / widget.count),
                  backgroundColor: Colors.white10,
                  color: remaining == 0 ? Colors.green : const Color(0xFFD4AF37),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
