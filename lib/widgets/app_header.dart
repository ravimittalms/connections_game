import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLanguageChanged;

  const AppHeader({
    Key? key,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text(
        'Word Puzzle Master',
        style: TextStyle(
          color: Colors.blue[800],
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: Colors.blue[800],
            size: 26,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  onLanguageChanged: onLanguageChanged,
                ),
              ),
            );
          },
          tooltip: 'Settings',
        ),
        SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
