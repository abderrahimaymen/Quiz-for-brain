import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading assets
import 'package:csv/csv.dart'; // For CSV parsing
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import '../models/question_category.dart';
import '../utils/constants.dart';

class QuizProvider with ChangeNotifier {
  List<Question> _allQuestions = [];
  List<Question> _currentCategoryQuestions = [];
  int _currentQuestionIndex = 0;
  Question? _currentQuestion;

  int _score = 0;
  int _availableAttempts = Constants.baseDailyAttempts;
  DateTime? _lastPlayedDate;

  Timer? _questionTimer;
  int _timeLeft =
      Constants.questionTimeLimit; // Default time limit for each question
  bool _isAnswerSubmitted = false;
  bool? _isLastAnswerCorrect;

  bool _isLoadingQuestions = true; // To show loading state
  int _highScoreEasy = 0;
  int _highScoreMedium = 0;
  int _highScoreHard = 0;
  int _totalQuestionsAnswered = 0;
  int _totalCorrectAnswers = 0;

  // --- Getters for new stats ---
  int get highScoreEasy => _highScoreEasy;
  int get highScoreMedium => _highScoreMedium;
  int get highScoreHard => _highScoreHard;
  int get totalQuestionsAnswered => _totalQuestionsAnswered;
  int get totalCorrectAnswers => _totalCorrectAnswers;
  double get correctRatio => _totalQuestionsAnswered > 0
      ? (_totalCorrectAnswers / _totalQuestionsAnswered) * 100
      : 0.0;

  // --- Getters ---
  int get score => _score;
  int get availableAttempts => _availableAttempts;
  Question? get currentQuestion => _currentQuestion;
  int get timeLeft => _timeLeft;
  bool get isAnswerSubmitted => _isAnswerSubmitted;
  bool? get isLastAnswerCorrect => _isLastAnswerCorrect;
  bool get canPlay => _availableAttempts > 0;
  bool get isLoadingQuestions => _isLoadingQuestions;

  String get attemptsInfo {
    if (_lastPlayedDate == null) return "Initializing...";
    final today = DateTime.now();
    final lastPlayedDay = DateTime(
        _lastPlayedDate!.year, _lastPlayedDate!.month, _lastPlayedDate!.day);
    final currentDay = DateTime(today.year, today.month, today.day);

    if (lastPlayedDay.isBefore(currentDay)) {
      return "Welcome to a new day! $_availableAttempts attempts ready.";
    }
    return "$_availableAttempts attempts left for today.";
  }

  QuizProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoadingQuestions = true;
    notifyListeners();
    await _loadQuestionsFromCsv();
    await _loadProgress(); // Load progress after questions are potentially available
    _isLoadingQuestions = false;
    notifyListeners();
  }

  bool _isSoundEffectsEnabled = true;

  bool get isSoundEffectsEnabled => _isSoundEffectsEnabled;

  void toggleSoundEffects(bool value) {
    _isSoundEffectsEnabled = value;
    notifyListeners();
  }

  Future<void> _loadQuestionsFromCsv() async {
    try {
      final rawCsvData = await rootBundle.loadString('assets/questions.csv');
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(rawCsvData);

      _allQuestions.clear(); // Clear existing questions before loading new ones

      // Skip header row (index 0)
      for (var i = 1; i < csvTable.length; i++) {
        var row = csvTable[i];
        if (row.length >= 5) {
          // Ensure row has enough columns
          try {
            QuestionDifficulty category;
            switch (row[3].toString().toLowerCase()) {
              case 'easy':
                category = QuestionDifficulty.easy;
                break;
              case 'medium':
                category = QuestionDifficulty.medium;
                break;
              case 'hard':
                category = QuestionDifficulty.hard;
                break;
              default:
                print(
                    'Warning: Unknown category "${row[3]}" for question ID ${row[0]}. Skipping.');
                continue; // Skip this question
            }

            _allQuestions.add(
              Question(
                id: row[0].toString(),
                text: row[1].toString(),
                correctAnswerIndex: int.tryParse(row[2].toString()) ?? 0,
                category: QuestionCategory.history,
                points: int.tryParse(row[4].toString()) ?? 0,
                options: [
                  'Option 1',
                  'Option 2',
                  'Option 3',
                  'Option 4'
                ], // Add actual options from CSV
                difficulty: category,
                explanation: 'Explanation', // Add actual explanation from CSV
              ),
            );
          } catch (e) {
            print("Error parsing row $i: $row. Error: $e");
            // Optionally, skip this problematic row or handle more gracefully
          }
        } else {
          print(
              'Warning: Row $i does not have enough columns. Expected 5, got ${row.length}. Row data: $row. Skipping.');
        }
      }
      _allQuestions.shuffle();
      print("Loaded ${_allQuestions.length} questions from CSV.");
    } catch (e) {
      print("Error loading questions from CSV: $e");
      // Handle error, maybe load default questions or show an error message
      _allQuestions = [
        // Fallback questions if CSV loading fails
        Question(
            id: 'err1',
            text: 'Error loading. 2+2?',
            correctAnswerIndex: 0,
            category:  QuestionCategory.geography,
            difficulty: QuestionDifficulty.easy,
            points: 0,
            options: ['4', '3', '5', '6'],
            explanation: 'Basic arithmetic: 2+2=4')
      ];
    }
    notifyListeners(); // Notify even on error to update UI
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _score = prefs.getInt(Constants.prefsKeyTotalScore) ?? 0;

    String? lastPlayedDateString =
        prefs.getString(Constants.prefsKeyLastPlayedDate);
    int savedAttempts = prefs.getInt(Constants.prefsKeyAvailableAttempts) ??
        Constants.baseDailyAttempts;

    if (lastPlayedDateString == null) {
      _availableAttempts = Constants.baseDailyAttempts;
      _lastPlayedDate = DateTime.now();
    } else {
      _lastPlayedDate = DateTime.parse(lastPlayedDateString);
      DateTime today = DateTime.now();
      DateTime lastPlayedDay = DateTime(
          _lastPlayedDate!.year, _lastPlayedDate!.month, _lastPlayedDate!.day);
      DateTime currentDay = DateTime(today.year, today.month, today.day);

      if (lastPlayedDay.isBefore(currentDay)) {
        int rolloverAttempts = savedAttempts;
        _availableAttempts = (Constants.baseDailyAttempts + rolloverAttempts)
            .clamp(0, Constants.maxTotalAttempts);
        _lastPlayedDate = today;
      } else {
        _availableAttempts = savedAttempts.clamp(0,
            Constants.maxTotalAttempts); // Ensure it doesn't exceed max on load
      }
    }
    await _saveProgress(); // Save updated date/attempts. Crucial for first load.
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    if (_lastPlayedDate == null)
      _lastPlayedDate = DateTime.now(); // Ensure it's not null
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(Constants.prefsKeyTotalScore, _score);
    await prefs.setString(
        Constants.prefsKeyLastPlayedDate, _lastPlayedDate!.toIso8601String());
    await prefs.setInt(Constants.prefsKeyAvailableAttempts, _availableAttempts);
  }

  void selectCategory(QuestionDifficulty category) {
    if (!canPlay || _isLoadingQuestions) return;

    _currentCategoryQuestions =
        _allQuestions.where((q) => q.category == category).toList();
    _currentCategoryQuestions.shuffle();
    _currentQuestionIndex = 0;
    if (_currentCategoryQuestions.isNotEmpty) {
      _currentQuestion = _currentCategoryQuestions[_currentQuestionIndex];
      _startNewQuestion();
    } else {
      _currentQuestion = null;
      print("No questions available for category: $category");
      // Potentially show a message to the user
    }
    notifyListeners();
  }

  void selectDifficulty(QuestionDifficulty difficulty) {
    if (!canPlay || _isLoadingQuestions) return;

    _currentCategoryQuestions =
        _allQuestions.where((q) => q.difficulty == difficulty).toList();
    _currentCategoryQuestions.shuffle();
    _currentQuestionIndex = 0;
    if (_currentCategoryQuestions.isNotEmpty) {
      _currentQuestion = _currentCategoryQuestions[_currentQuestionIndex];
      _startNewQuestion();
    } else {
      _currentQuestion = null;
      print("No questions available for difficulty: $difficulty");
    }
    notifyListeners();
  }

  void _startNewQuestion() {
    _isAnswerSubmitted = false;
    _isLastAnswerCorrect = null;
    _timeLeft = Constants.questionTimeLimit;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isAnswerSubmitted) {
        // Stop timer if answer was submitted early
        timer.cancel();
        return;
      }
      if (_timeLeft > 0) {
        _timeLeft--;
      } else {
        timer.cancel(); // Ensure timer is cancelled before handling timeout
        _handleTimeout();
      }
      notifyListeners();
    });
  }

  void submitAnswer(String userAnswer) {
    if (_isAnswerSubmitted || !canPlay || _currentQuestion == null) return;

    _questionTimer?.cancel();
    _isAnswerSubmitted = true;
    bool correct = userAnswer.trim().toLowerCase() ==
        _currentQuestion!.answer.trim().toLowerCase();

    if (correct) {
      _score += _currentQuestion!.points;
      _isLastAnswerCorrect = true;
    } else {
      _availableAttempts =
          (_availableAttempts - 1).clamp(0, Constants.maxTotalAttempts);
      _isLastAnswerCorrect = false;
    }
    _saveProgress();
    notifyListeners();
  }

  void _handleTimeout() {
    if (_isAnswerSubmitted) return; // Already submitted

    _questionTimer?.cancel(); // Ensure timer is cancelled
    _isAnswerSubmitted = true;
    _isLastAnswerCorrect = false;
    _availableAttempts =
        (_availableAttempts - 1).clamp(0, Constants.maxTotalAttempts);
    _saveProgress();
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentCategoryQuestions.isEmpty || _isLoadingQuestions) return;

    if (!canPlay) {
      _currentQuestion = null;
      _questionTimer?.cancel();
      notifyListeners();
      return;
    }

    _currentQuestionIndex++;
    if (_currentQuestionIndex < _currentCategoryQuestions.length) {
      _currentQuestion = _currentCategoryQuestions[_currentQuestionIndex];
      _startNewQuestion();
    } else {
      // End of category
      _currentQuestion = null;
      _questionTimer?.cancel();
      // Consider showing a "Category Complete" message
    }
    notifyListeners();
  }

  // Call this if user leaves quiz screen prematurely or category ends
  void endQuizSession() {
    _questionTimer?.cancel();
    _currentQuestion = null;
    _currentCategoryQuestions.clear();
    _currentQuestionIndex = 0;
    notifyListeners();
  }

  // --- New Getters for Quiz Status ---
  int get currentQuestionIndex => _currentQuestionIndex;
  List<Question> get categoryQuestions => _currentCategoryQuestions;
  bool get hasMoreQuestions =>
      _currentQuestionIndex < _currentCategoryQuestions.length - 1;

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }
}
