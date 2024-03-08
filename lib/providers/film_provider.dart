import 'package:flutter/material.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/services/film_service.dart';

class FilmProvider with ChangeNotifier {
  final FilmService _filmService = FilmService();
  List<Film>? _films;

  Iterable<Film>? get films => _films;

  FilmProvider() {
    loadFilms();
  }

  Future<void> loadFilms() async {
    _films = await _filmService.getFilms();
    notifyListeners();
  }
}
