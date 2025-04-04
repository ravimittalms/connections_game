import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/puzzle_model.dart';

class PuzzleService {
  final Random _random = Random();
  List<Map<String, dynamic>>? _cachedGames;

  Future<Game> loadGame() async {
    try {
      // Load and cache games if not already cached
      if (_cachedGames == null) {
        final String jsonString = await rootBundle.loadString('assets/data/games.json');
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        _cachedGames = List<Map<String, dynamic>>.from(jsonData['games']);
      }

      // Select random game
      final gameData = _cachedGames![_random.nextInt(_cachedGames!.length)];
      print('Selected game with title: ${gameData['groups'][0]['title']}');
      
      return Game.fromJson(gameData);
    } catch (e) {
      print('Error loading game: $e');
      rethrow;
    }
  }
}
