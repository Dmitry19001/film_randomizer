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

  Future<bool> createFilm(Film film) async {
    Film?  createdFilm = await _filmService.createFilm(film.toJson());

    loadFilms();
    return createdFilm != null;
  }

  Future<bool> updateFilm(Film film) async {
    Film? updatedFilm = await _filmService.updateFilm(film.id!, film.toJson());

    loadFilms();
    return updatedFilm != null;
  }

  Future<void> filterWatched() async {
    if(_films == null) return;

    _films = _films!.where((film) => !film.isWatched).toList();
    notifyListeners();
  }
}
