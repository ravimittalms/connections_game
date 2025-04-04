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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: _buildActionButton(
                onPressed: onShuffle,
                icon: Icons.shuffle,
                label: 'Shuffle',
                color: Colors.orange[400]!,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: _buildActionButton(
                onPressed: onDeselect,
                icon: Icons.clear_all,
                label: 'Deselect',
                color: Colors.red[400]!,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: _buildActionButton(
                onPressed: onSubmit,
                icon: Icons.check_circle,
                label: 'Submit',
                color: Colors.green[400]!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
