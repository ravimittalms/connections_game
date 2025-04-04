class Group {
  final String title;
  final String color;
  final List<String> words;

  Group({
    required this.title,
    required this.color,
    required this.words,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      title: json['title'],
      color: json['color'],
      words: List<String>.from(json['words']),
    );
  }
}

class Game {
  final List<Group> groups;
  List<String> allWords;  // Changed to non-final to allow shuffling

  Game({required this.groups}) : allWords = _getAllWords(groups) {
    // Shuffle words when game is created
    allWords.shuffle();
  }

  static List<String> _getAllWords(List<Group> groups) {
    List<String> words = [];
    for (var group in groups) {
      words.addAll(group.words);
    }
    return words;
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('groups')) {
      throw Exception('Invalid game data: missing groups');
    }

    final List<dynamic> groupsList = json['groups'] as List;
    if (groupsList.isEmpty) {
      throw Exception('Game has no groups');
    }

    final groups = groupsList
        .map((group) => Group.fromJson(Map<String, dynamic>.from(group)))
        .toList();

    return Game(groups: groups);
  }
}
