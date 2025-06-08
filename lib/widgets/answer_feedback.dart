import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_colors.dart';

class AnswerFeedback extends StatelessWidget {
  final bool isCorrect;
  final String? correctAnswer; // Optional: to show the correct answer

  const AnswerFeedback({
    Key? key,
    required this.isCorrect,
    this.correctAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
        ScaleEffect(begin: Offset(0.8, 0.8) ,duration: 300.ms, curve: Curves.elasticOut)
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isCorrect ? AppColors.correct.withOpacity(0.1) : AppColors.incorrect.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCorrect ? AppColors.correct : AppColors.incorrect, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCorrect ? Icons.check_circle_outline : Icons.highlight_off,
              color: isCorrect ? AppColors.correct : AppColors.incorrect,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? "Correct!" : "Incorrect!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? AppColors.correct : AppColors.incorrect,
                    ),
                  ),
                  if (!isCorrect && correctAnswer != null)
                    Text(
                      "Answer: $correctAnswer",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}