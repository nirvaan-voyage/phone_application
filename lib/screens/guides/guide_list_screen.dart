import 'package:flutter/material.dart';

import '../../core/data/guides_data.dart';
import '../../widgets/guide_card.dart';
import 'guide_details_screen.dart';

class GuideListScreen extends StatelessWidget {
  const GuideListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recommended Guides"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Local Guides For You",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Based on your travel preferences",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: guides.length,
                itemBuilder: (context, index) {
                  final guide = guides[index];

                  return GuideCard(
                    guide: guide,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuideDetailsScreen(
                            guide: guide,
                          ),
                        ),
                      );
                    },
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
