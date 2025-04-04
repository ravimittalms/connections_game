import 'package:flutter/material.dart';
import 'dart:math' show Random, pi, sin;
import '../widgets/app_header.dart';
import '../widgets/game_board.dart';
import '../widgets/mistakes_indicator.dart';
import '../widgets/action_buttons.dart';
import '../widgets/completed_group.dart';
import '../models/puzzle_model.dart';
import '../services/puzzle_service.dart';

class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  List<String> selectedItems = [];
  Game? currentGame;
  List<Group> completedGroups = [];
  final PuzzleService _puzzleService = PuzzleService();
  int mistakesRemaining = 4;
  late final AnimationController _shakeController;
  String? errorMessage;
  final Random _random = Random();
  bool isGameOver = false;
  
  bool get isGameComplete => currentGame != null && 
      completedGroups.length >= 4;  // Changed to check for exactly 4 groups

  bool get shouldShowGameBoard => !isGameComplete;

  @override
  void initState() {
    super.initState();
    _loadGame();
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadGame() async {
    try {
      print('Starting game load');
      final game = await _puzzleService.loadGame();
      print('Game loaded successfully: ${game.groups.length} groups');
      setState(() {
        currentGame = game;
        errorMessage = null;
      });
    } catch (e, stackTrace) {
      print('Error loading game: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        errorMessage = 'Failed to load game: $e';
      });
    }
  }

  Group? findGroupForSelection() {
    if (selectedItems.length != 4) return null;
    
    return currentGame?.groups.firstWhere(
      (group) => selectedItems.every((item) => 
        group.words.map((w) => w.toUpperCase()).contains(item.toUpperCase())
      ),
      orElse: () => Group(title: '', color: '', words: []),
    );
  }

  // Get remaining words that haven't been completed yet
  List<String> getRemainingWords() {
    Set<String> completedWords = {};
    for (var group in completedGroups) {
      completedWords.addAll(group.words);
    }
    return currentGame!.allWords
        .where((word) => !completedWords.contains(word))
        .toList();
  }

  void _handleWrongAnswer() {
    setState(() {
      mistakesRemaining--;
    });
    _shakeController.forward().then((_) => _shakeController.reset());
  }

  void _restartGame() {
    setState(() {
      mistakesRemaining = 4;
      isGameOver = false;
      selectedItems.clear();
      completedGroups.clear();
    });
    // Load a new random game
    _loadGame();
  }

  void handleSubmit() {
    if (selectedItems.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select 4 items before submitting'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    final group = findGroupForSelection();
    if (group != null && group.title.isNotEmpty) {
      setState(() {
        completedGroups.add(group);
        currentGame?.groups.remove(group);
        selectedItems.clear();
      });
    } else {
      if (mistakesRemaining > 0) {
        _handleWrongAnswer();
        // Only set game over if this was the last mistake
        if (mistakesRemaining <= 0) {
          setState(() {
            isGameOver = true;
          });
        }
      }
    }
  }

  void toggleSelection(String item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else if (selectedItems.length < 4) {
        selectedItems.add(item);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedItems.clear();
    });
  }

  void handleShuffle() {
    setState(() {
      List<String> remaining = getRemainingWords();
      // Fisher-Yates shuffle algorithm
      for (int i = remaining.length - 1; i > 0; i--) {
        int j = _random.nextInt(i + 1);
        String temp = remaining[i];
        remaining[i] = remaining[j];
        remaining[j] = temp;
      }
      // Update the game words with shuffled ones
      int index = 0;
      for (int i = 0; i < currentGame!.allWords.length; i++) {
        if (!completedGroups.any((group) => 
          group.words.contains(currentGame!.allWords[i]))) {
          currentGame!.allWords[i] = remaining[index++];
        }
      }
      // Clear selection after shuffle
      selectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $errorMessage'),
              ElevatedButton(
                onPressed: _loadGame,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (currentGame == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isGameOver) {
      return Scaffold(
        appBar: AppHeader(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Game Over!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('You ran out of attempts'),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _restartGame,
                child: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppHeader(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Create four groups of four!',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              // Show completed groups
              ...completedGroups.map((group) => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: CompletedGroup(
                  title: group.title,
                  items: group.words,
                  color: group.color,
                ),
              )),
              // Only show congratulations after all groups are complete
              if (isGameComplete) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Congratulations!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You have successfully completed the puzzle!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade900,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _restartGame,
                        child: Text('Play Next Puzzle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (shouldShowGameBoard) ...[
                Expanded(
                  child: AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final sineValue = sin(24 * _shakeController.value * pi) * 8;
                      return Transform.translate(
                        offset: Offset(sineValue, 0),
                        child: GameBoard(
                          words: getRemainingWords(),
                          selectedItems: selectedItems,
                          onItemSelected: toggleSelection,
                        ),
                      );
                    },
                  ),
                ),
                Divider(height: 32),
                MistakesIndicator(
                  mistakesRemaining: mistakesRemaining,
                ),
                SizedBox(height: 16),
                ActionButtons(
                  onShuffle: handleShuffle,
                  onDeselect: clearSelection,
                  onSubmit: handleSubmit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
