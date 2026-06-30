import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationState {
  const LocationState({
    required this.name,
    required this.iso2,
  });

  final String name;
  final String iso2;
}

class LocationApiService {
  LocationApiService._();

  static const String _apiKey =
      '069a1e91ac4cf1b379631b09c4860d06951668a9623535bc89ef841a2343232c';

  static const String _baseUrl = 'https://api.countrystatecity.in/v1';

  static Map<String, String> get _headers => {
        'X-CSCAPI-KEY': _apiKey,
      };

  static Future<List<LocationState>> fetchIndianStates() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/countries/IN/states'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load states');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map(
          (item) => LocationState(
            name: item['name'].toString(),
            iso2: item['iso2'].toString(),
          ),
        )
        .where((state) => state.name.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static Future<List<String>> fetchCitiesForState(String stateCode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/countries/IN/states/$stateCode/cities'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load cities');
    }

    final data = jsonDecode(response.body) as List<dynamic>;

    return data
        .map((item) => item['name'].toString())
        .where((city) => city.trim().isNotEmpty)
        .toList()
      ..sort();
  }
}
