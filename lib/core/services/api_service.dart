import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nirvaan/models/flight_model.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8080";

  // ── Existing Auth/OTP POST Method ──────────────────────────────────────────
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data["message"] ?? "Something went wrong");
  }

  // ── 1. New Generic GET Method ─────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    // Handles both your Auth error format ("message") and our Go router format ("error")
    throw Exception(data["error"] ?? data["message"] ?? "Something went wrong");
  }

  // ── 2. The Flight Search Integration ───────────────────────────────────────
  Future<List<Flight>> searchFlights(
      String from, String to, String date) async {
    try {
      // Use your clean new GET method!
      final response =
          await get('/api/flights/search?from=$from&to=$to&date=$date');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'];

        // Map the raw JSON list into clean Dart Flight objects
        return data.map((json) => Flight.fromJson(json)).toList();
      } else {
        throw Exception('Backend returned success: false');
      }
    } catch (e) {
      print('Flight Search Error: $e');
      return []; // Return an empty list on failure so your UI doesn't crash
    }
  }
}
