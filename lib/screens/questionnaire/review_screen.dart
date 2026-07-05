import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/questionnaire_provider.dart';
import '../../widgets/primary_button.dart';
import 'loading_screen.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionnaire = ref.watch(questionnaireProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Your Trip"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Please review your answers",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: questionnaire.answers.length,
                itemBuilder: (context, index) {
                  final entry = questionnaire.answers.entries.elementAt(index);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value),
                    ),
                  );
                },
              ),
            ),
            PrimaryButton(
              label: "Generate My Trip",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoadingScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
