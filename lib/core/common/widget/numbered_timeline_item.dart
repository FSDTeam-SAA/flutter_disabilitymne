import 'package:flutter/material.dart';

class NumberedTimelineItem extends StatelessWidget {
  final int number;
  final String text;
  final bool isLast;

  const NumberedTimelineItem({
    super.key,
    required this.number,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF4D7EA9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.white.withValues(alpha:  0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
