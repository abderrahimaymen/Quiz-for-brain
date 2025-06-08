import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/quiz_provider.dart';
import '../widgets/timer_indicator.dart';
import '../widgets/answer_feedback.dart';
import '../utils/app_colors.dart';
import '../models/question_model.dart';
// import '../utils/constants.dart';

class QuizScreen extends StatefulWidget {
  final QuestionDifficulty difficulty;
  const QuizScreen({super.key, required this.difficulty});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  AnimationController? _cardAnimationController;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController!,
      curve: Curves.easeInOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<QuizProvider>(context, listen: false).currentQuestion !=
          null) {
        _cardAnimationController?.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    _cardAnimationController?.dispose();
    super.dispose();
  }

  void _submit(QuizProvider provider) {
    if (_answerController.text.trim().isNotEmpty) {
      provider.submitAnswer(_answerController.text);
      _answerFocusNode.unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an answer."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  void _next(QuizProvider provider) {
    _answerController.clear();
    _cardAnimationController?.forward(from: 0.0);
    provider.nextQuestion();
    if (provider.currentQuestion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _answerFocusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, child) {
        final question = provider.currentQuestion;

        if (question == null && !provider.isLoadingQuestions) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                '${widget.difficulty.name.toUpperCase()} Quiz Complete',
                style: TextStyle(color: AppColors.primary),
              ),
              backgroundColor: AppColors.onPrimary,
              iconTheme: IconThemeData(color: AppColors.primary),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, size: 80, color: AppColors.secondary)
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  Text(
                    provider.canPlay
                        ? "Category Finished!"
                        : "No more attempts!",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 10),
                  Text(
                    "Your score: ${provider.score}",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.onSurface,
                        ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    icon: Icon(Icons.arrow_back, color: AppColors.onPrimary),
                    label: Text(
                      "Back to Categories",
                      style: TextStyle(color: AppColors.onPrimary),
                    ),
                    onPressed: () => Navigator.pop(context),
                  )
                      .animate()
                      .slideY(begin: 0.5, delay: 600.ms, duration: 400.ms),
                ],
              ),
            ),
          );
        }

        if (provider.isLoadingQuestions && question == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: Text(
                "Loading Quiz...",
                style: TextStyle(color: AppColors.onPrimary),
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${widget.difficulty.name.toUpperCase()} Challenge',
              style: TextStyle(color: AppColors.onPrimary),
            ),
            backgroundColor: AppColors.primary,
            iconTheme: IconThemeData(color: AppColors.onPrimary),
            automaticallyImplyLeading: !provider.isAnswerSubmitted,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: ${provider.score}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Attempts: ${provider.availableAttempts}',
                      style: TextStyle(
                        fontSize: 16,
                        color: provider.availableAttempts > 1
                            ? AppColors.onSurface
                            : AppColors.incorrect,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (question != null && !provider.isAnswerSubmitted)
                  TimerIndicator(timeLeft: provider.timeLeft)
                      .animate()
                      .fadeIn(duration: 300.ms),
                const SizedBox(height: 25),
                if (question != null)
                  SlideTransition(
                    position: _slideAnimation!,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              question.text,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Points: ${question.points}",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                if (provider.isAnswerSubmitted &&
                    provider.isLastAnswerCorrect != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: AnswerFeedback(
                      isCorrect: provider.isLastAnswerCorrect!,
                      correctAnswer: !provider.isLastAnswerCorrect!
                          ? question?.answer
                          : null,
                    ),
                  ),
                if (question != null && !provider.isAnswerSubmitted)
                  Column(
                    children: [
                      TextField(
                        controller: _answerController,
                        focusNode: _answerFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Your Answer Here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.surface.withOpacity(0.8),
                          prefixIcon: Icon(
                            Icons.question_answer_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(provider),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideX(begin: -0.5, duration: 400.ms),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.send, color: AppColors.onPrimary),
                        label: Text(
                          'Submit',
                          style: TextStyle(color: AppColors.onPrimary),
                        ),
                        onPressed: () => _submit(provider),
                      ).animate(
                        effects: [
                          ScaleEffect(
                            delay: 300.ms,
                            duration: 300.ms,
                            curve: Curves.elasticOut,
                          ),
                        ],
                      ),
                    ],
                  ),
                if (provider.isAnswerSubmitted)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.arrow_forward, color: AppColors.onPrimary),
                    label: Text(
                      provider.canPlay && provider.hasMoreQuestions
                          ? 'Next Question'
                          : 'Finish Category',
                      style: TextStyle(color: AppColors.onPrimary),
                    ),
                    onPressed: () => _next(provider),
                  ).animate().slideY(
                        begin: 1.0,
                        duration: 400.ms,
                        curve: Curves.easeInOut,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
