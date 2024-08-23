import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/services/genre_service.dart';
import 'package:flutter/material.dart';

class GenreProvider with ChangeNotifier {
  final GenreService _genreService = GenreService();
  final List<Genre> _genres = [];

  Iterable<Genre> get genres => _genres;

  GenreProvider() {
    loadGenres();
  }

  Future<void> loadGenres() async {
    final fetchedGenres = await _genreService.getGenres();

    if (fetchedGenres == null) return;
    
    _genres.clear();
    _genres.addAll(fetchedGenres);

    notifyListeners();
  }
}
