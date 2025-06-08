import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class TimerIndicator extends StatelessWidget {
  final int timeLeft;
  final int totalTime;

  const TimerIndicator({
    Key? key,
    required this.timeLeft,
    this.totalTime = Constants.questionTimeLimit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = timeLeft / totalTime;
    Color progressColor = AppColors.secondaryLight;
    if (progress < 0.3) {
      progressColor = Colors.orange;
    }
    if (progress < 0.15) {
      progressColor = AppColors.incorrect;
    }

    return Column(
      children: [
        Text(
          "Time Left: $timeLeft s",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textLight),
        ),
        const SizedBox(height: 8),
        Animate(
          effects: [ShakeEffect(hz: timeLeft < 5 && timeLeft > 0 ? 3 : 0, duration: 300.ms)],
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.backgroundDark.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ),
      ],
    );
  }
}