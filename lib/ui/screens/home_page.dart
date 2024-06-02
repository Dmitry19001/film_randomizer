import 'package:film_randomizer/providers/settings_provider.dart';
import 'package:film_randomizer/ui/screens/film_add_edit_page.dart';
import 'package:film_randomizer/ui/widgets/bottom_navigation_widget.dart';
import 'package:film_randomizer/ui/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/providers/film_provider.dart'; 
import 'package:film_randomizer/ui/widgets/film_detail_widget.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static String routeName = "/";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FilmProvider _filmProvider;
  Iterable<Film>? _films;

  @override
  void initState() {
    _filmProvider = Provider.of<FilmProvider>(context, listen: false);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await _syncFilms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          _syncFilms(settingsProvider.showWatched);
          return _films != null
              ? ListView.builder(
                  itemCount: _films!.length,
                  itemBuilder: (context, index) {
                    Film film = _films!.elementAt(index);
                    return FilmDetailWidget(film: film);
                  },
                )
              : const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FilmEditPage(film: Film())),
          )
        },
      ),
      bottomNavigationBar: CustomBottomNavigation(
        onSync: () async => {_syncFilms()},
      ),
    );
  }

  Future<void> _syncFilms([bool? showWatched]) async {
    await _filmProvider.loadFilms();

    if (showWatched != null && !showWatched) {
      await _filmProvider.filterWatched();
    }

    setState(() {
      _films = _filmProvider.films;
    });
  }
}
