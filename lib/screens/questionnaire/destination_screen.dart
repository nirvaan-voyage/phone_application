import 'package:flutter/material.dart';
import '../../widgets/input_field.dart';
import '../../widgets/primary_button.dart';
import 'QuestionnaireScreen.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  final TextEditingController destinationController = TextEditingController();

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  void _continue() {
    if (destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your destination."),
        ),
      );
      return;
    }

    // Provider will be added next

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QuestionnaireScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Your Trip"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Where would you like to travel?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Enter your destination to begin creating your personalized itinerary.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              InputField(
                label: "Destination",
                hint: "e.g. Goa, Manali, Bali",
                controller: destinationController,
              ),
              const Spacer(),
              PrimaryButton(
                label: "Continue",
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
