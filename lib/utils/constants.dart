class Constants {
  // Base game settings
  static const int baseDailyAttempts = 5;
  static const int maxTotalAttempts = 10;
  static const int questionTimeLimit = 30; // seconds

  // SharedPreferences keys
  static const String prefsKeyTotalScore = 'totalScore';
  static const String prefsKeyLastPlayedDate = 'lastPlayedDate';
  static const String prefsKeyAvailableAttempts = 'availableAttempts';
  static const String prefsKeyHighScoreEasy = 'highScoreEasy';
  static const String prefsKeyHighScoreMedium = 'highScoreMedium';
  static const String prefsKeyHighScoreHard = 'highScoreHard';
  static const String prefsKeyTotalQuestionsAnswered = 'totalQuestionsAnswered';
  static const String prefsKeyTotalCorrectAnswers = 'totalCorrectAnswers';
}
