// places_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  final String baseUrl = "http://universities.hipolabs.com/search?name=";

  Future<List<String>> getInstitutions(String query) async {
    final List<String> categories = [
      query,
      "$query engineering",
      "$query medical",
      "$query college",
      "$query institute"
    ];

    final Set<String> resultsSet = {};

    for (final term in categories) {
      final url = Uri.parse("$baseUrl$term");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        for (var u in data) {
          resultsSet.add(u['name'] as String);
        }
      } else {
        throw Exception("Failed to load institutions for $term");
      }
    }

    return resultsSet.toList();
  }
}