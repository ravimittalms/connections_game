import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/puzzle_model.dart';

class PuzzleService {
  final Random _random = Random();
  Map<String, List<Game>>? _cachedGames;

  Future<Game> loadGame({required String difficulty}) async {
    try {
      if (_cachedGames == null) {
        final String jsonString = await rootBundle.loadString('assets/data/games.json');
        print('Loading games for difficulty: $difficulty');

        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        if (!jsonMap.containsKey('difficulty_levels')) {
          throw Exception('Invalid JSON structure: missing difficulty_levels');
        }

        final Map<String, dynamic> difficulties = jsonMap['difficulty_levels'];
        _cachedGames = {};

        // Updated difficulty levels list to include Pro
        for (var level in ['Beginner', 'Intermediate', 'Advanced', 'Pro']) {
          if (difficulties.containsKey(level)) {
            List gamesList = difficulties[level];
            _cachedGames![level] = gamesList
                .map((game) => Game.fromJson(game))
                .toList();
            print('Loaded ${_cachedGames![level]?.length} games for $level');
          }
        }
      }

      if (!_cachedGames!.containsKey(difficulty)) {
        throw Exception('Invalid difficulty: $difficulty');
      }

      final games = _cachedGames![difficulty]!;
      if (games.isEmpty) {
        throw Exception('No games available for difficulty: $difficulty');
      }

      final randomGame = games[_random.nextInt(games.length)];
      print('Successfully loaded game for difficulty: $difficulty');
      return randomGame;
    } catch (e) {
      print('Error loading game: $e');
      throw Exception('Failed to load game: $e');
    }
  }
}
