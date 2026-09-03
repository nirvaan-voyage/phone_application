import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/generated_itinerary.dart';

class ItineraryService {
  ItineraryService({
    this.baseUrl = const String.fromEnvironment(
      'NIRVAAN_API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8080',
    ),
  });

  final String baseUrl;

  Future<GeneratedItinerary> generate({
    required String destination,
    required Map<String, dynamic> answers,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/itinerary/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'destination': destination,
            'answers': answers,
          }),
        )
        .timeout(const Duration(seconds: 45));

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return GeneratedItinerary.fromJson(body);
    }

    throw Exception(
        body['message'] ?? body['error'] ?? 'Could not generate itinerary');
  }
}
