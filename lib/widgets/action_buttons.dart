import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onShuffle;
  final VoidCallback onDeselect;
  final VoidCallback onSubmit;

  const ActionButtons({
    required this.onShuffle,
    required this.onDeselect,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: onShuffle,
          child: Text('Shuffle'),
        ),
        ElevatedButton(
          onPressed: onDeselect,
          child: Text('Deselect All'),
        ),
        ElevatedButton(
          onPressed: onSubmit,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
