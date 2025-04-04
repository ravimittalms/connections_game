import 'package:flutter/material.dart';

class MistakesIndicator extends StatelessWidget {
  final int mistakesRemaining;

  const MistakesIndicator({
    required this.mistakesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Mistakes Remaining',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(width: 16),
          Row(
            children: List.generate(4, (index) {
              final isActive = index < mistakesRemaining;
              return Container(
                width: 16,
                height: 16,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.black : Colors.grey[300],
                  border: Border.all(
                    color: isActive ? Colors.black : Colors.grey[400]!,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ] : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
