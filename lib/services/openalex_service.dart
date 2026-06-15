import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/work.dart';

class OpenAlexException implements Exception {
  final String message;
  final int? statusCode;

  OpenAlexException(this.message, {this.statusCode});

  @override
  String toString() => 'OpenAlexException: $message (Status: $statusCode)';
}

class OpenAlexService {
  static const String _baseUrl = 'api.openalex.org';

  /// Fetches top works matching the search [keyword].
  /// Optionally accepts [apiKey] to authorize the request.
  Future<List<Work>> fetchWorks(String keyword, {String? apiKey}) async {
    final Map<String, String> queryParameters = {
      'search': keyword,
      'per_page': '50',
      'sort': 'cited_by_count:desc',
    };

    if (apiKey != null && apiKey.trim().isNotEmpty) {
      queryParameters['api_key'] = apiKey.trim();
    }

    final uri = Uri.https(_baseUrl, '/works', queryParameters);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results == null) {
          return [];
        }
        return results.map((workJson) => Work.fromJson(workJson)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw OpenAlexException(
          'API Key is invalid or expired. Please check your OpenAlex credentials in Settings.',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 429) {
        throw OpenAlexException(
          'Rate limit exceeded. Please configure an OpenAlex API Key in Settings to get a higher limit.',
          statusCode: response.statusCode,
        );
      } else {
        throw OpenAlexException(
          'Failed to load works from OpenAlex. Error code ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is OpenAlexException) rethrow;
      throw OpenAlexException('Network error: Check your internet connection.\nDetails: $e');
    }
  }

  /// Fetches publication counts per year for the [keyword] to build the trend chart.
  Future<Map<int, int>> fetchTrendData(String keyword, {String? apiKey}) async {
    final Map<String, String> queryParameters = {
      'search': keyword,
      'group_by': 'publication_year',
    };

    if (apiKey != null && apiKey.trim().isNotEmpty) {
      queryParameters['api_key'] = apiKey.trim();
    }

    final uri = Uri.https(_baseUrl, '/works', queryParameters);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final groups = data['group_by'] as List<dynamic>?;
        
        final Map<int, int> trends = {};
        if (groups != null) {
          for (var group in groups) {
            final yearStr = group['key']?.toString();
            final countVal = group['count'];
            if (yearStr != null && countVal != null) {
              final year = int.tryParse(yearStr);
              final count = int.tryParse(countVal.toString());
              if (year != null && count != null) {
                // Filter out unrealistic years
                if (year > 1800 && year <= DateTime.now().year + 1) {
                  trends[year] = count;
                }
              }
            }
          }
        }
        return trends;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw OpenAlexException(
          'API Key is invalid or expired.',
          statusCode: response.statusCode,
        );
      } else {
        throw OpenAlexException(
          'Failed to load publication trends.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is OpenAlexException) rethrow;
      throw OpenAlexException('Failed to load publication trends due to a connection error.');
    }
  }
}
