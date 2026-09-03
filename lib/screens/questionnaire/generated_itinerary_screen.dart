import 'package:flutter/material.dart';

import '../../models/generated_itinerary.dart';

class GeneratedItineraryScreen extends StatelessWidget {
  const GeneratedItineraryScreen({
    super.key,
    required this.itinerary,
  });

  final GeneratedItinerary itinerary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your Itinerary'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            itinerary.summary,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 20),
          ...itinerary.days.map((day) => _DayCard(day: day)),
          const SizedBox(height: 20),
          const Text(
            'Matched Guides',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...itinerary.matchedGuides
              .map((guide) => _GuideMatchCard(guide: guide)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final ItineraryDay day;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day ${day.day}: ${day.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _PlanLine(label: 'Morning', value: day.morning),
            _PlanLine(label: 'Afternoon', value: day.afternoon),
            _PlanLine(label: 'Evening', value: day.evening),
            if (day.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    day.notes.map((note) => Chip(label: Text(note))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanLine extends StatelessWidget {
  const _PlanLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(height: 1.35),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _GuideMatchCard extends StatelessWidget {
  const _GuideMatchCard({required this.guide});

  final MatchedGuide guide;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(guide.name.isEmpty ? '?' : guide.name[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                          '${guide.city} • ${guide.rating} rating • ₹${guide.pricePerDay}/day'),
                    ],
                  ),
                ),
                Text('${guide.matchScore}%'),
              ],
            ),
            const SizedBox(height: 12),
            Text(guide.about),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: guide.matchReasons
                  .map((reason) => Chip(label: Text(reason)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
