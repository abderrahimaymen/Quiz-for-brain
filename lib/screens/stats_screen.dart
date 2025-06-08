import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 36, color: iconColor)
                .animate()
                .scale(delay: 200.ms, duration: 300.ms),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    final easyColor = theme.brightness == Brightness.light
        ? AppColors.correctLight
        : AppColors.correctDark;
    final mediumColor = theme.brightness == Brightness.light
        ? Colors.orangeAccent
        : Colors.tealAccent[100]!;
    final hardColor = theme.brightness == Brightness.light
        ? AppColors.incorrectLight
        : AppColors.incorrectDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Performance'),
        actions: [
          Consumer<QuizProvider>(builder: (context, quizProv, child) {
            return IconButton(
              icon: Icon(quizProv.isSoundEffectsEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded),
              tooltip: "Toggle Sound Effects",
              onPressed: () {
                quizProv.toggleSoundEffects(!quizProv.isSoundEffectsEnabled);
              },
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatCard(
                context,
                'Total Score',
                quizProvider.score.toString(),
                Icons.star_rounded,
                theme.colorScheme.secondary),
            const SizedBox(height: 10),
            Text("High Scores (Overall):",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            _buildStatCard(
                context,
                'Easy Category High',
                quizProvider.highScoreEasy.toString(),
                Icons.emoji_events_rounded,
                easyColor),
            _buildStatCard(
                context,
                'Medium Category High',
                quizProvider.highScoreMedium.toString(),
                Icons.emoji_events_rounded,
                mediumColor),
            _buildStatCard(
                context,
                'Hard Category High',
                quizProvider.highScoreHard.toString(),
                Icons.emoji_events_rounded,
                hardColor),
            const SizedBox(height: 20),
            Text("Accuracy:",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            _buildStatCard(
                context,
                'Correct Answers',
                quizProvider.totalCorrectAnswers.toString(),
                Icons.check_circle_outline_rounded,
                easyColor),
            _buildStatCard(
                context,
                'Total Answered',
                quizProvider.totalQuestionsAnswered.toString(),
                Icons.help_outline_rounded,
                theme.colorScheme.onSurface.withOpacity(0.6)),
            _buildStatCard(
                context,
                'Correct Ratio',
                '${quizProvider.correctRatio.toStringAsFixed(1)}%',
                Icons.pie_chart_outline_rounded,
                theme.colorScheme.primary),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Reset functionality coming soon!")));
              },
              child: const Text('More Stats Coming Soon'),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
