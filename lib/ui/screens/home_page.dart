import 'package:film_randomizer/notifiers/film_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:film_randomizer/notifiers/settings_notifier.dart';

import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/ui/screens/film_add_edit_page.dart';
import 'package:film_randomizer/ui/screens/randomizer_page.dart';
import 'package:film_randomizer/ui/widgets/bottom_navigation_widget.dart';
import 'package:film_randomizer/ui/widgets/film_detail_widget.dart';
import 'package:film_randomizer/ui/widgets/main_app_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static String routeName = "/";

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  bool _initialSyncDone = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final filmsAsync    = ref.watch(filmProvider);

    ref.listen<bool>(
      // select out the inner boolean (default to false if loading)
      settingsProvider.select(
        (async) => async.value?.showWatched ?? false,
      ),
      (previous, next) {
        if (previous != next) {
          // debug/log to confirm it’s firing
          debugPrint('showWatched changed: $previous → $next');
          _syncFilms(next);
        }
      },
      // you can also do fireImmediately: true if you want an initial sync here
    );

    // 2) Defer the *very first* sync once settings have arrived
    if (!_initialSyncDone) {
      _initialSyncDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncFilms(settingsAsync.value?.showWatched ?? false);
      });
    }

    return Scaffold(
      appBar: const MainAppBar(),
      body: filmsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading settings: $err'),
        ),
        data: (settings) {
          // We rely on ref.listen above to call _syncFilms when showWatched changes.
          // Here, we simply display the current film list from filmProvider.

          return filmsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Error loading films: $err'),
            ),
            data: (films) {
              // If the film list is empty, show a message or something else
              if (films.isEmpty) {
                return const Center(child: Text('No films found.'));
              }

              return ListView.builder(
                itemCount: films.length,
                itemBuilder: (context, index) {
                  final film = films[index];
                  return FilmDetailWidget(film: film);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FilmEditPage(film: Film())),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNavigation(
        onSync: () async {
          // Manually sync again if user clicks refresh
          // We'll read the current showWatched from settings
          final currentSettings = ref.read(settingsProvider).value;
          final showWatched = currentSettings?.showWatched;
          await _syncFilms(showWatched);
        },
        onOpenRandomizer: () {
          // We'll rely on the current filmProvider data
          // If you want to pass those films directly, read filmProvider's state
          final filmList = ref.read(filmProvider).maybeWhen(
            data: (films) => films,
            orElse: () => <Film>[],
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RandomizeScreen(films: filmList),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------------
  // Private method to sync films from the server and apply filtering
  // ----------------------------------------------------------------
  Future<void> _syncFilms([bool? showWatched]) async {
    // 1) Reload all films
    await ref.read(filmProvider.notifier).reloadFilms(showWatched:showWatched ?? false);
  }
}
