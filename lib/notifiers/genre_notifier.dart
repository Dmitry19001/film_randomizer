import 'dart:async';

import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/notifiers/backend_ip_notifier.dart';
import 'package:film_randomizer/services/genre_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Our Riverpod provider for the genre list.
/// In other words, `ref.watch(genreProvider)` gives you an `AsyncValue<List<Film>>`.
final genreProvider =
    AsyncNotifierProvider<GenreNotifier, List<Genre>>(GenreNotifier.new);

class GenreNotifier extends AsyncNotifier<List<Genre>> {
  @override
  FutureOr<List<Genre>> build() async {
    // Called once when the provider is first read.
    // We'll load the genres from the server here.
    final genres = await _loadGenres();
    // If loading fails, you could return an empty list or throw an error
    return genres ?? <Genre>[];
  }
  
  Future<List<Genre>?>? _loadGenres() async {
    final service = _createGenreService();
    return await service.getGenres();
  }

    /// Reloads the list of genres from the server and updates [state].
  Future<void> reloadGenres() async {
    state = const AsyncValue.loading();
    try {
      final genres = await _loadGenres();
      if (genres == null) {
        // If null, treat as error
        state = const AsyncValue.error('Failed to load genres', StackTrace.empty);
      } else {
        state = AsyncValue.data(genres);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }


  /// Helper method to create a GenreService with the current baseUrl
  GenreService _createGenreService() {
    final ipState = ref.read(backendIPProvider).valueOrNull;
    final baseUrl = ipState?.apiBaseUrl ?? 'http://localhost:3002/api';

    return GenreService(baseUrl);
  }

}