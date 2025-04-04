import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {
  final List<String> words;
  final List<String> selectedItems;
  final Function(String) onItemSelected;

  const GameBoard({
    required this.words,
    required this.selectedItems,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate height based on available space
        // but keep it between 350-500 pixels
        double height = constraints.maxHeight * 0.6;
        height = height.clamp(350.0, 500.0);

        return SizedBox(
          height: height,
          child: AspectRatio(
            aspectRatio: 1.0, // Keep grid square
            child: GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
              children: words.map((text) {
                final isSelected = selectedItems.contains(text);
                return InkWell(
                  onTap: () => onItemSelected(text),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
