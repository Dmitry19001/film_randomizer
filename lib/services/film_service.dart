import 'dart:convert';
import 'package:film_randomizer/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/film.dart'; // Make sure this path matches your Film model

class FilmService {
  final String _baseUrl = "$apiBaseUrl/films";
  final logger = Logger();

  Future<List<Film>?> getFilms() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        Iterable jsonResponse = json.decode(response.body);
        List<Film> films = List<Film>.from(jsonResponse.map((model) => Film.fromJson(model)));
        return films;
      } else {
        logger.e('Failed to load films: ${response.body}');
      }
    } catch (e) {
      logger.e('Error fetching films: $e');
    }
    return null;
  }

  Future<Film?> getFilm(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
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

  Future<Film?> createFilm(Map<String, dynamic> filmData) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(filmData),
      );
      if (response.statusCode == 201) {
        return Film.fromJson(json.decode(response.body));
      } else {
        logger.e('Failed to create film: ${response.body}');
      }
    } catch (e) {
      logger.e('Error creating film: $e');
    }
    return null;
  }

  Future<Film?> updateFilm(String id, Map<String, dynamic> filmData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(filmData),
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
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
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
