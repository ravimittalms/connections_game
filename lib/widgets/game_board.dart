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
    // Calculate responsive dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;
    
    // Responsive tile dimensions
    final double tileWidth = (screenWidth - (isSmallScreen ? 48 : 64)) / 4;
    final double tileHeight = screenHeight * 0.09; // 9% of screen height
    final double fontSize = isSmallScreen ? 12.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: isSmallScreen ? 6 : 8,
        crossAxisSpacing: isSmallScreen ? 6 : 8,
        childAspectRatio: tileWidth / tileHeight,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Prevent scrolling
        children: words.map((word) {
          final isSelected = selectedItems.contains(word);
          return Material(
            elevation: isSelected ? 8 : 2,
            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
            color: isSelected ? Colors.blue[200] : Colors.white,
            child: InkWell(
              onTap: () => onItemSelected(word),
              borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
              child: Container(
                height: tileHeight,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 4 : 8,
                  vertical: isSmallScreen ? 2 : 4,
                ),
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
