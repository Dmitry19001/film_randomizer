import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/services/genre_service.dart';
import 'package:flutter/material.dart';

class GenreProvider with ChangeNotifier {
  final GenreService _genreService = GenreService();
  List<Genre>? _categories;

  Iterable<Genre>? get categories => _categories;

  GenreProvider() {
    loadGenres();
  }

  Future<void> loadGenres() async {
    _categories = await _genreService.getGenres();
    notifyListeners();
  }
}
