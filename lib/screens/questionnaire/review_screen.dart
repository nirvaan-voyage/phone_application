import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/questionnaire_provider.dart';
import '../../widgets/primary_button.dart';
import '../guides/guide_list_screen.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionnaire = ref.watch(questionnaireProvider);

    final titles = {
      "age_group": "Age Group",
      "companions": "Travelling With",
      "trip_type": "Trip Type",
      "accommodation": "Accommodation",
      "transportation": "Transportation",
      "food": "Food Preference",
      "pace": "Travel Pace",
      "hidden_gems": "Hidden Gems",
      "guide": "Local Guide",
      "accessibility": "Accessibility",
      "attractions": "Favourite Attractions",
      "activities": "Activities",
      "start_time": "Daily Start Time",
    };

    final icons = {
      "age_group": Icons.person_outline,
      "companions": Icons.groups_outlined,
      "trip_type": Icons.flight_takeoff_outlined,
      "accommodation": Icons.hotel_outlined,
      "transportation": Icons.directions_transit_outlined,
      "food": Icons.restaurant_outlined,
      "pace": Icons.speed_outlined,
      "hidden_gems": Icons.diamond_outlined,
      "guide": Icons.badge_outlined,
      "accessibility": Icons.accessible_outlined,
      "attractions": Icons.place_outlined,
      "activities": Icons.hiking_outlined,
      "start_time": Icons.schedule_outlined,
    };

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Review Your Trip"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Please review your answers",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: questionnaire.answers.length,
                itemBuilder: (context, index) {
                  final entry = questionnaire.answers.entries.elementAt(index);

                  final value = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              icons[entry.key],
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              titles[entry.key] ?? entry.key,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (value is List)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: value.map<Widget>((item) {
                              return Chip(
                                avatar: const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: Text(item),
                                backgroundColor: Theme.of(context).primaryColor,
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          )
                        else
                          Text(
                            value.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: "Generate My Trip",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GuideListScreen(),
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
