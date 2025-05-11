import 'dart:convert';
import 'package:film_randomizer/util/safe_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'package:film_randomizer/models/film.dart';

class FilmService {
  final String baseUrl;
  final String token;
  final Ref ref;

  FilmService({
    required this.baseUrl,
    required this.token,
    required this.ref,
  });

  final logger = Logger();

  Future<List<Film>?> getFilms() async {
    try {
      logger.d('Fetching films from $baseUrl/films');
      logger.d('Authorization: Bearer $token');

      final response = await safeRequest(
        () => http.get(
          Uri.parse("$baseUrl/films"),
          headers: {'Authorization': 'Bearer $token'},
        ),
        ref,
      );

      if (response.statusCode != 200) {
        logger.e('Failed to load films: ${response.body}');
        return null;
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) {
        logger.e('Unexpected JSON format (not a List): $decoded');
        return null;
      }

      final List<Film> films = [];
      for (var i = 0; i < decoded.length; i++) {
        final entry = decoded[i];
        try {
          if (entry is Map<String, dynamic>) {
            films.add(Film.fromJson(entry));
          } else {
            throw FormatException('Expected Map<String, dynamic>, got ${entry.runtimeType}');
          }
        } catch (e) {
          logger.e(
            'Error parsing film at index $i:\n'
            '  JSON: $entry\n'
            '  Error: $e'
          );
        }
      }

      return films;
    } catch (e) {
      logger.e('Error fetching films: $e');
      return null;
    }
  }

  Future<Film?> getFilm(String id) async {
    try {
      final response = await safeRequest(
        () => http.get(
          Uri.parse('$baseUrl/films/$id'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        ref
      );

      if (response.statusCode == 200) {
        return Film.fromJson(json.decode(response.body));
      } else {
        logger.e('Failed to load film: ${response.body}');
      }
    } catch (e) {
      logger.e('Error fetching film: $e');
    }
    return null;
  }

  Future<Film?> postFilm(Map<String, dynamic> filmData) async {
    try {
      final response = await safeRequest(
        () => http.post(
          Uri.parse("$baseUrl/films"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(filmData),
        ),
        ref
      );

      if (response.statusCode == 201) {
        return Film.fromJson(json.decode(response.body));
      } else {
        logger.e('Failed to post film: ${response.body}');
      }
    } catch (e) {
      logger.e('Error creating film: $e');
    }
    return null;
  }

  Future<Film?> updateFilm(String id, Map<String, dynamic> filmData) async {
    try {
      final response = await safeRequest(
        () => http.put(
          Uri.parse('$baseUrl/films/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(filmData),
        ),
        ref
      );

      if (response.statusCode == 200) {
        return Film.fromJson(json.decode(response.body));
      } else {
        logger.e('Failed to update film: ${response.body}');
      }
    } catch (e) {
      logger.e('Error updating film: $e');
    }
    return null;
  }

  Future<bool> deleteFilm(String id) async {
    try {
      final response = await safeRequest(
        () => http.delete(
          Uri.parse('$baseUrl/films/$id'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        ref
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        logger.e('Failed to delete film: ${response.body}');
      }
    } catch (e) {
      logger.e('Error deleting film: $e');
    }
    return false;
  }
}
