import 'package:flutter/material.dart';
import 'dart:math' show Random, pi, sin;
import '../widgets/app_header.dart';
import '../widgets/game_board.dart';
import '../widgets/mistakes_indicator.dart';
import '../widgets/action_buttons.dart';
import '../widgets/completed_group.dart';
import '../models/puzzle_model.dart';
import '../services/puzzle_service.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';

class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<String> selectedItems = [];
  Game? currentGame;
  List<Group> completedGroups = [];
  final PuzzleService _puzzleService = PuzzleService();
  int mistakesRemaining = 4;
  late final AnimationController _shakeController;
  late final AnimationController _rotationController;
  String? errorMessage;
  final Random _random = Random();
  bool isGameOver = false;
  String selectedDifficulty = 'Beginner';

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
    _rotationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadGame() async {
    try {
      final settings = Provider.of<SettingsModel>(context, listen: false);
      final game = await _puzzleService.loadGame(
        difficulty: selectedDifficulty,
        language: settings.selectedLanguage,
      );
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
    _loadGame(); // This will now use the current selectedDifficulty
  }

  void handleSubmit() {
    if (selectedItems.length < 4) {
      // Calculate screen width
      final screenWidth = MediaQuery.of(context).size.width;
      // Use the smaller of 600 or screen width - 32 (for padding)
      final snackBarWidth = screenWidth > 632 ? 600.0 : screenWidth - 32;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            alignment: Alignment.center,
            height: 32,
            child: Text(
              'Please select 4 items before submitting',
              textAlign: TextAlign.center,
            ),
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: (screenWidth - snackBarWidth) / 2,
            right: (screenWidth - snackBarWidth) / 2,
          ),
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

  Widget _buildGameOverImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * pi,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.blue.shade200,
                      Colors.blue.shade800,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Icon(
          Icons.psychology,
          size: 80,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 20,
            ),
          ),
          Text(
            'Difficulty:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
              letterSpacing: 0.5,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150),
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.blue[50],
              ),
              child: DropdownButton<String>(
                value: selectedDifficulty,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue[800], size: 24),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[900],
                  fontWeight: FontWeight.w500,
                ),
                underline: Container(
                  height: 2,
                  color: Colors.blue[400],
                ),
                items: ['Beginner', 'Intermediate', 'Advanced', 'Pro']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedDifficulty = newValue;
                      _restartGame();
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
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
        appBar: AppHeader(
          onLanguageChanged: _restartGame, // Add this line
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGameOverImage(),
                SizedBox(height: 24),
                Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Keep going! Every attempt makes you stronger.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 300),
                  child: ElevatedButton(
                    onPressed: _restartGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.blue.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Score: ${completedGroups.length} groups found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        onLanguageChanged: _restartGame,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600, // Constrain maximum width
              maxHeight: MediaQuery.of(context).size.height * 0.9, // 90% of screen height
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align to top
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        'WORD PUZZLE MASTER',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Connect the Words, Master the Puzzle!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
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
                  _buildDifficultySelector(),
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
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Select four words that share a category, then click Submit. You have 4 lifelines.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
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
      ),
    );
  }
}
