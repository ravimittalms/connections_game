import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {},
      ),
      title: Text('Games'),
      actions: [
        IconButton(
          icon: Icon(Icons.lightbulb_outline),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.bar_chart),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
