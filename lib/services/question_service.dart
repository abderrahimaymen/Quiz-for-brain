import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/question_category.dart';

class QuestionService {
  static Future<List<Question>> loadQuestions() async {
    try {
      final String csvData =
          await rootBundle.loadString('assets/questions.csv');
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvData);

      // Remove header row
      csvTable.removeAt(0);

      return csvTable.map((row) {
        final id = row[0].toString();
        final text = row[1].toString();
        final answer = row[2].toString();
        final category = row[3].toString();
        final points = int.tryParse(row[4].toString()) ?? 10;

        // Extract difficulty from ID prefix (e: easy, m: medium, h: hard)
        final difficultyPrefix = id[0].toLowerCase();
        final difficulty = switch (difficultyPrefix) {
          'e' => QuestionDifficulty.easy,
          'm' => QuestionDifficulty.medium,
          'h' => QuestionDifficulty.hard,
          _ => QuestionDifficulty.medium,
        };

        // Generate plausible incorrect options based on answer type
        final allAnswers = [answer];
        if (int.tryParse(answer) != null) {
          // For numeric answers, generate nearby numbers
          final num = int.parse(answer);
          allAnswers.addAll([
            (num + 1).toString(),
            (num - 1).toString(),
            (num + 2).toString(),
          ]);
        } else {
          // For text answers, add generic options
          while (allAnswers.length < 4) {
            final fakeAnswer = 'Option ${allAnswers.length + 1}';
            if (!allAnswers.contains(fakeAnswer)) {
              allAnswers.add(fakeAnswer);
            }
          }
        }
        allAnswers.shuffle();

        return Question(
          id: id,
          text: text,
          options: allAnswers,
          correctAnswerIndex: allAnswers.indexOf(answer),
          difficulty: difficulty,
          category: _parseCategory(category),
          explanation: 'The correct answer is: $answer',
          points: points,
        );
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error loading questions: $e\n$stackTrace');
      return [];
    }
  }

  static Future<List<Question>> getQuestionsByDifficulty(
      QuestionDifficulty difficulty) async {
    final questions = await loadQuestions();
    return questions.where((q) => q.difficulty == difficulty).toList();
  }

  static Future<List<Question>> getQuestionsByCategory(String category) async {
    final questions = await loadQuestions();
    return questions
        .where((q) =>
            q.category.toString().toLowerCase() == category.toLowerCase())
        .toList();
  }

  static Future<List<Question>> getFilteredQuestions({
    QuestionDifficulty? difficulty,
    String? category,
    int limit = 10,
  }) async {
    var questions = await loadQuestions();

    if (difficulty != null) {
      questions = questions.where((q) => q.difficulty == difficulty).toList();
    }

    if (category != null) {
      questions = questions
          .where((q) =>
              q.category.toString().toLowerCase() == category.toLowerCase())
          .toList();
    }

    questions.shuffle();
    return questions.take(limit).toList();
  }

  static QuestionCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'science':
        return QuestionCategory.science;
      case 'history':
        return QuestionCategory.history;
      case 'geography':
        return QuestionCategory.geography;
      case 'literature':
        return QuestionCategory.literature;
      case 'math':
      case 'mathematics':
        return QuestionCategory.math;
      case 'tech':
      case 'technology':
        return QuestionCategory.tech;
      case 'sports':
        return QuestionCategory.sports;
      case 'arts':
        return QuestionCategory.arts;
      default:
        debugPrint(
            'Warning: Unknown category "$category". Defaulting to Science.');
        return QuestionCategory.science;
    }
  }
}
