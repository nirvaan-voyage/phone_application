import 'package:flutter/material.dart';

import '../../models/guide.dart';
import '../../widgets/primary_button.dart';

class GuideDetailsScreen extends StatelessWidget {
  final Guide guide;

  const GuideDetailsScreen({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(guide.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person,
                size: 100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              guide.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              guide.city,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              guide.about,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "Languages",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Wrap(
              spacing: 8,
              children:
                  guide.languages.map((e) => Chip(label: Text(e))).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              "Specialties",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Wrap(
              spacing: 8,
              children:
                  guide.specialties.map((e) => Chip(label: Text(e))).toList(),
            ),
            const SizedBox(height: 30),
            PrimaryButton(
              label: "Book Guide",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Booking feature coming soon!"),
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
