import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import '../screens/quiz_screen.dart';
import '../widgets/category_card.dart';
import '../utils/app_colors.dart';
import '../providers/theme_provider.dart';
import '../screens/stats_screen.dart';
import '../models/question_category.dart';
import '../models/question_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _navigateToQuizScreen(
      BuildContext context, QuestionDifficulty difficulty) {
    final provider = Provider.of<QuizProvider>(context, listen: false);

    if (provider.isLoadingQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Questions are loading, please wait...")),
      );
      return;
    }
    if (provider.canPlay) {
      provider.selectDifficulty(difficulty);
      // Check if questions were actually loaded for the difficulty
      if (provider.currentQuestion != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => QuizScreen(difficulty: difficulty)),
        ).then((_) {
          // When QuizScreen is popped, refresh home screen data potentially
          provider.endQuizSession(); // Ensure quiz state is reset
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "No questions available for ${difficulty.name}. Try another difficulty or check CSV.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text("No attempts left for today. Come back tomorrow!"),
          backgroundColor: AppColors.incorrect,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final themeProvider =
        Provider.of<ThemeProvider>(context); // Get ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'BrainSpark Quiz' /* style: TextStyle(fontWeight: FontWeight.bold) already handled by AppBarTheme */),
        // backgroundColor: AppColors.primary, // Handled by AppBarTheme
        // elevation: 2,
        actions: [
          IconButton(
            // Theme Toggle Button
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              themeProvider
                  .toggleTheme(themeProvider.themeMode != ThemeMode.dark);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Animate(
                key: ValueKey(quizProvider.score),
                effects: [
                  ShimmerEffect(
                      duration: const Duration(milliseconds: 800),
                      color: Theme.of(context).colorScheme.secondary)
                ], // Use theme color
                child: Text(
                  'Score: ${quizProvider.score}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary), // Use theme color
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          // Subtle gradient based on theme
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Animate(
                effects: [
                  FadeEffect(duration: 600.ms),
                  SlideEffect(begin: const Offset(0, -0.2), duration: 500.ms)
                ],
                child: Card(
                  // elevation: 2, // Handled by CardTheme
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Handled by CardTheme
                  // color: AppColors.surface, // Handled by CardTheme
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Welcome to BrainSpark!",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight:
                                      FontWeight.bold), // Use theme color
                        ),
                        const SizedBox(height: 8),
                        Animate(
                          key: ValueKey(quizProvider.availableAttempts),
                          effects: [
                            ScaleEffect(
                                duration: 300.ms, curve: Curves.easeOutBack)
                          ],
                          child: Text(
                            quizProvider.attemptsInfo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                color: quizProvider.canPlay
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurface // Use theme color
                                    : Theme.of(context)
                                        .colorScheme
                                        .error, // Use theme error color
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              if (quizProvider.isLoadingQuestions)
                Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context)
                            .colorScheme
                            .primary)) // Use theme color
              else
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.0,
                    children: [
                      CategoryCard(
                        title: 'Easy Peasy',
                        icon: Icons.sentiment_very_satisfied,
                        // Use theme-aware colors or specific light/dark if distinction is needed
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? AppColors.correctDark
                            : AppColors.correctLight,
                        enabled: quizProvider.canPlay,
                        onTap: () => _navigateToQuizScreen(
                            context, QuestionDifficulty.easy),
                      )
                          .animate()
                          .slideX(delay: 200.ms, duration: 400.ms, begin: -1),
                      CategoryCard(
                        title: 'Medium Grind',
                        icon: Icons.psychology,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.tealAccent[100]!
                            : Colors.orangeAccent,
                        enabled: quizProvider.canPlay,
                        onTap: () => _navigateToQuizScreen(
                            context, QuestionDifficulty.medium),
                      )
                          .animate()
                          .slideX(delay: 300.ms, duration: 400.ms, begin: 1),
                      CategoryCard(
                        title: 'Hard Challenge',
                        icon: Icons.whatshot,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? AppColors.incorrectDark
                            : AppColors.incorrectLight,
                        enabled: quizProvider.canPlay,
                        onTap: () => _navigateToQuizScreen(
                            context, QuestionDifficulty.hard),
                      )
                          .animate()
                          .slideX(delay: 400.ms, duration: 400.ms, begin: -1),
                      CategoryCard(
                        title: 'My Stats',
                        icon: Icons.bar_chart_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Use theme color
                        enabled: true,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const StatsScreen())); // Navigate to StatsScreen
                        },
                      )
                          .animate()
                          .slideX(delay: 500.ms, duration: 400.ms, begin: 1),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              if (!quizProvider.canPlay && !quizProvider.isLoadingQuestions)
                Center(
                    child: Text(
                  "See you tomorrow for more challenges!",
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500), // Use theme color
                )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .shake(hz: 2, duration: 500.ms)),
            ],
          ),
        ),
      ),
    );
  }
}
