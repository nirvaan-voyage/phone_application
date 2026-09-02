import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/travel_search_item.dart';

class TravelSearchService {
  TravelSearchService({
    this.baseUrl = const String.fromEnvironment(
      'NIRVAAN_API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8080',
    ),
  });

  final String baseUrl;

  Future<List<TravelSearchItem>> search({
    required String category,
    String? from,
    String? to,
    String? date,
    String? city,
  }) async {
    final params = <String, String>{};
    if (from != null && from.trim().isNotEmpty) params['from'] = from.trim();
    if (to != null && to.trim().isNotEmpty) params['to'] = to.trim();
    if (date != null && date.trim().isNotEmpty) params['date'] = date.trim();
    if (city != null && city.trim().isNotEmpty) params['city'] = city.trim();

    final uri = Uri.parse('$baseUrl/api/travel/$category')
        .replace(queryParameters: params.isEmpty ? null : params);
    final response = await http.get(uri).timeout(const Duration(seconds: 30));
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'] as List<dynamic>? ?? [];
      return data
          .map(
              (item) => TravelSearchItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
        body['message'] ?? body['error'] ?? 'Could not load $category');
  }
}
