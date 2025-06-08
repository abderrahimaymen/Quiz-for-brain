import 'question_category.dart';

enum QuestionDifficulty { easy, medium, hard }

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final QuestionDifficulty difficulty;
  final QuestionCategory category;
  final String explanation;
  final int points;

  String get answer => options[correctAnswerIndex];

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.difficulty,
    required this.category,
    required this.explanation,
    this.points = 10, // Default points value
  });

  bool isCorrectAnswer(String userAnswer) {
    return userAnswer.trim().toLowerCase() == answer.trim().toLowerCase();
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      difficulty: QuestionDifficulty.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (json['difficulty'] as String).toLowerCase(),
        orElse: () => QuestionDifficulty.medium,
      ),
      category:  QuestionCategory.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            (json['category'] as String).toLowerCase(),
        orElse: () => QuestionCategory.science,
      ),
      explanation: json['explanation'] as String,
      points: json['points'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'difficulty': difficulty.toString().split('.').last.toLowerCase(),
        'category': category,
        'explanation': explanation,
        'points': points,
      };
}
