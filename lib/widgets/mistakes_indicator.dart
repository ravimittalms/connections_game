import 'package:flutter/material.dart';

class MistakesIndicator extends StatelessWidget {
  final int mistakesRemaining;

  const MistakesIndicator({
    required this.mistakesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Mistakes Remaining:'),
        Row(
          children: List.generate(4, (index) {
            final isActive = index < mistakesRemaining;
            return Container(
              width: 10,
              height: 10,
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.grey[300],
                border: Border.all(color: Colors.black),
                shape: BoxShape.rectangle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
