import 'package:flutter/material.dart';

class CompletedGroup extends StatelessWidget {
  final String title;
  final List<String> items;
  final String color;

  const CompletedGroup({
    required this.title,
    required this.items,
    required this.color,
  });

  Color _getColor() {
    switch (color.toLowerCase()) {
      case 'purple':
        return Colors.purple;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _getColor(),
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          Text(
            items.join(', ').toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
