import 'package:flutter/material.dart';

class ItineraryQuestionnaireScreen extends StatefulWidget {
  const ItineraryQuestionnaireScreen({super.key});

  @override
  State<ItineraryQuestionnaireScreen> createState() =>
      _ItineraryQuestionnaireScreenState();
}

class _ItineraryQuestionnaireScreenState
    extends State<ItineraryQuestionnaireScreen> {
  int currentQuestion = 0;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "What type of destination do you prefer?",
      "options": ["Beach", "Mountains", "City", "Spiritual"]
    },
    {
      "question": "How long is your trip?",
      "options": ["1-3 Days", "4-7 Days", "1-2 Weeks", "2+ Weeks"]
    },
    {
      "question": "Who are you travelling with?",
      "options": ["Solo", "Couple", "Friends", "Family"]
    },
    {
      "question": "What is your budget?",
      "options": ["Budget", "Moderate", "Luxury", "Ultra Luxury"]
    },
    {
      "question": "Preferred accommodation?",
      "options": ["Hotel", "Resort", "Hostel", "Homestay"]
    },
    {
      "question": "Preferred transport?",
      "options": ["Flight", "Train", "Road Trip", "Any"]
    },
  ];

  List<String> selectedAnswers = List.filled(6, '');

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SummaryScreen(
            answers: selectedAnswers,
            questions: questions,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Your Itinerary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
            ),
            const SizedBox(height: 30),
            Text(
              "Question ${currentQuestion + 1}/${questions.length}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              q["question"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: q["options"].length,
                itemBuilder: (context, index) {
                  final option = q["options"][index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      onPressed: () {
                        selectedAnswers[currentQuestion] = option;

                        nextQuestion();
                      },
                      child: Text(option),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final List<String> answers;
  final List<Map<String, dynamic>> questions;

  const SummaryScreen({
    super.key,
    required this.answers,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Summary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Your Preferences",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(questions[index]["question"]),
                      subtitle: Text(answers[index]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Generate Itinerary Clicked",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Generate Itinerary",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
