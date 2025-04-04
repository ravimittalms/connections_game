import 'package:flutter/foundation.dart';

class SettingsModel extends ChangeNotifier {
  String _selectedLanguage = 'English';

  String get selectedLanguage => _selectedLanguage;

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }
}
