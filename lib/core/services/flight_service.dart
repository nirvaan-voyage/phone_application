import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nirvaan/models/flight_model.dart'; // Grabs the model we built in Step 1

class FlightService {
  // Using your laptop's exact Wi-Fi IP address!
  // Change this line:
  static const String baseUrl = 'http://127.0.0.1:8080/api';

  Future<List<Flight>> fetchLiveFlights() async {
    try {
      // 1. Send the GET request to your Go backend
      final response = await http.get(Uri.parse('$baseUrl/flights'));

      // 2. Check if the server gave us a "200 OK" success response
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        // 3. Extract the actual array of flights from the 'data' key
        final List<dynamic> flightData = body['data'];

        // 4. Loop through the raw JSON and convert it into clean Flutter 'Flight' objects
        return flightData.map((json) => Flight.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Could not connect to backend. Make sure Go is running! Error: $e');
    }
  }
}
