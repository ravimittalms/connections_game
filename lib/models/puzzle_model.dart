import 'dart:math';

class Game {
  final List<Group> groups;
  late final List<String> allWords;

  Game({
    required this.groups,
  }) {
    allWords = [];
    for (var group in groups) {
      allWords.addAll(group.words);
    }
    allWords.shuffle(Random());
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    final groupsList = (json['groups'] as List)
        .map((groupJson) => Group.fromJson(groupJson))
        .toList();
    return Game(groups: groupsList);
  }
}

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
      title: json['title'] as String,
      color: json['color'] as String,
      words: (json['words'] as List).cast<String>(),
    );
  }
}
