import 'package:film_randomizer/notifiers/film_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:film_randomizer/notifiers/settings_notifier.dart';
import 'package:film_randomizer/states/settings_state.dart';

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

  bool _didRegisterListener = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didRegisterListener) {
      _didRegisterListener = true;

      // 1) Listen to settings changes
      ref.listen<AsyncValue<SettingsState>>(
        settingsProvider,
        (previous, next) async {
          final prevShowWatched = previous?.value?.showWatched;
          final nextShowWatched = next.value?.showWatched;
          if (nextShowWatched != null && prevShowWatched != nextShowWatched) {
            await _syncFilms(nextShowWatched);
          }
        },
      );

      // 2) Defer the initial sync
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncFilms();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    // Watch the films from filmProvider
    final filmsAsync = ref.watch(filmProvider);

    return Scaffold(
      appBar: const MainAppBar(),
      body: settingsAsync.when(
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
    await ref.read(filmProvider.notifier).reloadFilms();

    // 2) If showWatched is false, filter out watched films
    if (showWatched != null && !showWatched) {
      await ref.read(filmProvider.notifier).filterWatched();
    }
  }
}
