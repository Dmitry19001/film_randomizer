import 'dart:async';
import 'package:film_randomizer/notifiers/auth_notifier.dart';
import 'package:film_randomizer/notifiers/backend_ip_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/services/film_service.dart';


/// Our Riverpod provider for the film list.
/// In other words, `ref.watch(filmProvider)` gives you an `AsyncValue<List<Film>>`.
final filmProvider =
    AsyncNotifierProvider<FilmNotifier, List<Film>>(FilmNotifier.new);

class FilmNotifier extends AsyncNotifier<List<Film>> {
  @override
  FutureOr<List<Film>> build() async {
    // Called once when the provider is first read.
    // We'll load the films from the server here.
    final films = await _loadFilms();
    // If loading fails, you could return an empty list or throw an error
    return films ?? <Film>[];
  }

  /// Helper method to create a FilmService with the current baseUrl & token
  FilmService _createFilmService() {
    final ipState = ref.read(backendIPProvider).valueOrNull;
    final baseUrl = ipState?.apiBaseUrl ?? 'http://localhost:3002/api';

    final authState = ref.read(authProvider).valueOrNull;
    final token = authState?.token ?? '';

    return FilmService(
      baseUrl: baseUrl,
      token: token,
      ref: ref,
    );
  }

  /// Loads the list of films from the server (returns null on error).
  Future<List<Film>?> _loadFilms() async {
    final service = _createFilmService();
    return await service.getFilms();
  }

  /// Reloads the list of films from the server and updates [state].
  Future<void> reloadFilms() async {
    state = const AsyncValue.loading();
    try {
      final films = await _loadFilms();
      if (films == null) {
        // If null, treat as error
        state = const AsyncValue.error('Failed to load films', StackTrace.empty);
      } else {
        state = AsyncValue.data(films);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // --------------------------------------------------------------------------
  // Public methods for creating, updating, deleting, filtering
  // --------------------------------------------------------------------------

  /// Create a new film on the server, then reload the list.
  Future<bool> createFilm(Film film) async {
    final service = _createFilmService();
    final created = await service.postFilm(film.toJson());
    if (created != null) {
      await reloadFilms();
      return true;
    }
    return false;
  }

  /// Update an existing film on the server, then reload the list.
  Future<bool> updateFilm(Film film) async {
    if (film.id == null) return false;

    final service = _createFilmService();
    final updated = await service.updateFilm(film.id!, film.toJson());
    if (updated != null) {
      await reloadFilms();
      return true;
    }
    return false;
  }

  /// Delete an existing film from the server, then reload the list.
  Future<bool> deleteFilm(Film film) async {
    if (film.id == null) return false;

    final service = _createFilmService();
    final result = await service.deleteFilm(film.id!);
    if (result) {
      await reloadFilms();
      return true;
    }
    return false;
  }

  /// Locally filter out watched films.
  /// This does NOT call the server; it just modifies the local list in [state].
  Future<void> filterWatched() async {
    // If we're currently in a loading/error state, skip for now.
    final current = state.valueOrNull;
    if (current == null) return;

    final filtered = current.where((film) => !film.isWatched).toList();
    // Update the state with the filtered list
    state = AsyncValue.data(filtered);
  }
}