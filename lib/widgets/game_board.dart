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
    // Calculate fixed dimensions for tiles
    final double tileWidth = (MediaQuery.of(context).size.width - 64) / 4;
    final double tileHeight = 60.0; // Fixed height for each tile
    final double fontSize = 14.0; // Fixed font size

    return Container(
      padding: EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: tileWidth / tileHeight,
        shrinkWrap: true,
        children: words.map((word) {
          final isSelected = selectedItems.contains(word);
          return Material(
            elevation: isSelected ? 8 : 2,
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.blue[200] : Colors.white,
            child: InkWell(
              onTap: () => onItemSelected(word),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: tileHeight,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    word,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
