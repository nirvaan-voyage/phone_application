import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/questionnaire_data.dart';
import '../../providers/questionnaire_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/question_option_card.dart';
import 'review_screen.dart'; // <-- Make sure this exists
import '../../widgets/progress_bar.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  @override
  Widget build(BuildContext context) {
    final questionnaire = ref.watch(questionnaireProvider);

    final currentQuestion =
        questionnaireQuestions[questionnaire.currentQuestion];

    final isLastQuestion =
        questionnaire.currentQuestion == questionnaireQuestions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Question ${questionnaire.currentQuestion + 1} of ${questionnaireQuestions.length}",
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentQuestion.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            ProgressBar(
              currentQuestion: questionnaire.currentQuestion + 1,
              totalQuestions: questionnaireQuestions.length,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];

                  return QuestionOptionCard(
                    title: option,
                    isSelected: currentQuestion.multiple
                        ? ((questionnaire.answers[currentQuestion.id]
                                    as List<dynamic>?)
                                ?.contains(option) ??
                            false)
                        : questionnaire.answers[currentQuestion.id] == option,
                    onTap: () {
                      if (currentQuestion.multiple) {
                        ref
                            .read(questionnaireProvider.notifier)
                            .toggleMultiAnswer(
                              currentQuestion.id,
                              option,
                            );
                      } else {
                        ref.read(questionnaireProvider.notifier).saveAnswer(
                              currentQuestion.id,
                              option,
                            );
                      }
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                if (questionnaire.currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(questionnaireProvider.notifier)
                            .previousQuestion();
                      },
                      child: const Text("Previous"),
                    ),
                  ),
                if (questionnaire.currentQuestion > 0)
                  const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: isLastQuestion ? "Finish" : "Next",
                    onPressed: () {
                      final answer = questionnaire.answers[currentQuestion.id];

                      if (answer == null ||
                          (answer is List && answer.isEmpty)) {
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please select an option.",
                              ),
                            ),
                          );
                          return;
                        }
                      }

                      if (isLastQuestion) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReviewScreen(),
                          ),
                        );
                        return;
                      }

                      ref.read(questionnaireProvider.notifier).nextQuestion();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
