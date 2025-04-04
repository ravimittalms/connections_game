import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLanguageChanged;

  const SettingsScreen({
    Key? key,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the current language from settings model
    final settings = Provider.of<SettingsModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.blue[800]),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            tooltip: 'Home',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            _buildLanguageOption('English', 'English', settings),
                            Divider(height: 1),
                            _buildLanguageOption('हिंदी', 'Hindi', settings),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Container(
              width: 200,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onLanguageChanged();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,  // Ensure white text
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,  // Explicitly set text color
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String label, String value, SettingsModel settings) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
        ),
      ),
      value: value,
      groupValue: settings.selectedLanguage,
      onChanged: (String? newValue) {
        if (newValue != null) {
          settings.setLanguage(newValue);
        }
      },
      activeColor: Colors.blue[800],
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
