import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/services/genre_service.dart';
import 'package:flutter/material.dart';

class GenreProvider with ChangeNotifier {
  final GenreService _genreService = GenreService();
  List<Genre>? _genres;

  Iterable<Genre>? get genres => _genres;

  GenreProvider() {
    loadGenres();
  }

  Future<void> loadGenres() async {
    _genres = await _genreService.getGenres();
    notifyListeners();
  }
}
