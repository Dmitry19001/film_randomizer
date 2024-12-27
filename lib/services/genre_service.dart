import 'dart:convert';
import 'package:film_randomizer/models/genre.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class GenreService {
  final String baseUrl;
  final Logger _logger = Logger();

  GenreService(this.baseUrl);

  Future<List<Genre>?> getGenres() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/genres"));
      if (response.statusCode == 200) {
        List<dynamic> genreJsonList = json.decode(response.body);
        List<Genre> genres = genreJsonList.map((genreJson) => Genre.fromJson(genreJson)).toList();
        return genres;
      } else {
        _logger.e('Failed to load genres: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error fetching genres: $e');
    }
    return null;
  }
}
