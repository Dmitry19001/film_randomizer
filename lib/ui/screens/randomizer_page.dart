import 'dart:async';
import 'dart:math';
import 'package:film_randomizer/models/base/localizable.dart';
import 'package:film_randomizer/models/category.dart';
import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/notifiers/category_notifier.dart';
import 'package:film_randomizer/notifiers/genre_notifier.dart';
import 'package:film_randomizer/ui/widgets/film_detail_widget.dart';
import 'package:film_randomizer/ui/widgets/multi_select_field.dart';
import 'package:film_randomizer/util/random_utilities.dart';
import 'package:film_randomizer/generated/localization_accessors.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- NEW import
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RandomizeScreen extends ConsumerStatefulWidget {
  final Iterable<Film>? films;
  const RandomizeScreen({super.key, this.films});
  static String routeName = "/randomizer";

  @override
  ConsumerState<RandomizeScreen> createState() => _RandomizeScreenState();
}

class _RandomizeScreenState extends ConsumerState<RandomizeScreen>
    with SingleTickerProviderStateMixin {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ScrollOffsetController _scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  final ScrollOffsetListener _scrollOffsetListener = ScrollOffsetListener.create();

  Iterable<Film> _films = [];
  Iterable<Film> _filteredFilms = [];
  Iterable<Genre> _genres = [];
  Iterable<Category> _categories = [];

  List<Genre> _genresToFilter = [];
  List<Category> _categoriesToFilter = [];

  int? _selectedFilmIndex;
  bool _includeWatched = false; // fixed typo _includeWathced -> _includeWatched
  bool _genresFilterIncludeMode = true;
  bool _categoriesFilterIncludeMode = true;

  @override
  void initState() {
    super.initState();

    // Load genres & categories (like we used to do with Provider.of(...))
    // We'll do it after the first frame so we can safely use ref.read(...)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Reload from your new Riverpod providers
      await ref.read(genreProvider.notifier).reloadGenres();
      await ref.read(categoryProvider.notifier).reloadCategories();

      // Now read the current data from these providers
      final loadedGenres = ref.read(genreProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <Genre>[],
      );
      final loadedCategories = ref.read(categoryProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <Category>[],
      );

      setState(() {
        _genres = loadedGenres;
        _categories = loadedCategories;
        _films = widget.films ?? [];
      });

      _filterFilms(_films);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.films == null || widget.films!.isEmpty) {
      Fluttertoast.showToast(msg: L10nAccessor.get(context, "missing_films"));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nAccessor.get(context, "randomizer_page")),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _buildFilmRandomList(),
          ),
          _buildFilterControls(),
        ],
      ),
      floatingActionButton: _buildRandomizeButton(),
    );
  }

  // ----------------------------------------------------------------
  // Filter Controls
  // ----------------------------------------------------------------
  Widget _buildFilterControls() {
    return Expanded(
      flex: 5,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              CheckboxMenuButton(
                value: _includeWatched,
                onChanged: (include) {
                  setState(() => _includeWatched = include ?? false);
                  _filterFilms(_films);
                },
                child: Text(L10nAccessor.get(context, "include_watched")),
              ),
              ..._buildMultiSelectFields(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMultiSelectFields() {
    return [
      const SizedBox(height: 8),
      if (_genres.isNotEmpty)
        _buildFilterRow(
          selectedItems: _genresToFilter,
          includeMode: _genresFilterIncludeMode,
          toggleIncludeMode: () => setState(() {
            _genresFilterIncludeMode = !_genresFilterIncludeMode;
          }),
          clearSelectedItems: () {
            setState(() => _genresToFilter = []);
            _filterFilms(_films);
          },
          multiselect: MultiSelectField<Genre>(
            context: context,
            items: _genres.toList(),
            title: L10nAccessor.get(context, "genres"),
            buttonText: L10nAccessor.get(context, "select_genres"),
            selectedItems: _genresToFilter,
            onConfirm: (items) {
              setState(() => _genresToFilter = items.toList());
              _filterFilms(_films);
            },
            onChipTap: (item) {
              setState(() {
                _genresToFilter.remove(item);
                _genresToFilter = _genresToFilter.toList();
              });
              _filterFilms(_films);
            },
            buttonIconData: Icons.album,
          ),
        ),
      const SizedBox(height: 8),
      if (_categories.isNotEmpty)
        _buildFilterRow(
          selectedItems: _categoriesToFilter,
          includeMode: _categoriesFilterIncludeMode,
          toggleIncludeMode: () => setState(() {
            _categoriesFilterIncludeMode = !_categoriesFilterIncludeMode;
          }),
          clearSelectedItems: () {
            setState(() => _categoriesToFilter = []);
            _filterFilms(_films);
          },
          multiselect: MultiSelectField<Category>(
            context: context,
            items: _categories.toList(),
            title: L10nAccessor.get(context, "categories"),
            buttonText: L10nAccessor.get(context, "select_categories"),
            selectedItems: _categoriesToFilter,
            onConfirm: (items) {
              setState(() => _categoriesToFilter = items.toList());
              _filterFilms(_films);
            },
            onChipTap: (item) {
              setState(() {
                _categoriesToFilter.remove(item);
                _categoriesToFilter = _categoriesToFilter.toList();
              });
              _filterFilms(_films);
            },
            buttonIconData: Icons.category,
          ),
        ),
    ];
  }

  Widget _buildFilterRow({
    required bool includeMode,
    required MultiSelectField multiselect,
    required VoidCallback toggleIncludeMode,
    required List<Localizable> selectedItems,
    required VoidCallback clearSelectedItems,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(includeMode ? Icons.add : Icons.remove),
          color: includeMode ? Colors.green : Colors.red,
          onPressed: toggleIncludeMode,
          tooltip: L10nAccessor.get(context, "switch_include_mode"),
        ),
        Expanded(child: multiselect),
        if (selectedItems.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearSelectedItems,
            color: Colors.red,
          ),
      ],
    );
  }

  // ----------------------------------------------------------------
  // Film Random List
  // ----------------------------------------------------------------
  Widget _buildFilmRandomList() {
    return Stack(
      children: [
        ScrollablePositionedList.builder(
          itemCount: _filteredFilms.length + 1,
          itemScrollController: _itemScrollController,
          scrollOffsetController: _scrollOffsetController,
          itemPositionsListener: _itemPositionsListener,
          scrollOffsetListener: _scrollOffsetListener,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            if (index < _filteredFilms.length) {
              final film = _filteredFilms.elementAt(index);
              return _buildFilmListEntry(index, film);
            } else {
              return SizedBox(height: MediaQuery.of(context).size.height);
            }
          },
        ),
        _buildOverlay(context),
      ],
    );
  }

  Container _buildFilmListEntry(int index, Film film) {
    final isSelected = index == _selectedFilmIndex;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: isSelected
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).highlightColor.withOpacity(0.75),
                  spreadRadius: 4,
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            )
          : null,
      child: Text(
        film.title ?? '',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.3, 0.4],
                colors: <Color>[
                  Colors.transparent,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                tileMode: TileMode.mirror,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------
  // Randomize Button
  // ----------------------------------------------------------------
  Widget _buildRandomizeButton() {
    return FloatingActionButton(
      onPressed: _handleRandomize,
      child: const Icon(Icons.shuffle),
    );
  }

  // Perform the randomization
  void _handleRandomize() {
    // Reset scroll
    _itemScrollController.jumpTo(index: 0);

    // Re-filter the main list
    _filterFilms(_films);

    // Shuffle the list a bit
    setState(() {
      _filteredFilms = randomizeSize(_filteredFilms);
    });

    // Pick a random film from the second half
    _selectedFilmIndex = Random().nextInt(_filteredFilms.length);
    if (_selectedFilmIndex! < (_filteredFilms.length / 2).ceil()) {
      _selectedFilmIndex = _selectedFilmIndex! + (_filteredFilms.length / 2).ceil();
    }

    if (_selectedFilmIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _itemScrollController.scrollTo(
          index: _selectedFilmIndex!,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOutSine,
        );

        Timer(const Duration(milliseconds: 2200), _showFilmDetails);
      });
    }
  }

  // Show details of the selected film
  void _showFilmDetails() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.1, end: 1.0).animate(animation),
          child: SafeArea(
            child: FilmDetailWidget(
              film: _filteredFilms.elementAt(_selectedFilmIndex!),
              showAdditionalControls: true,
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------------
  // Local Filtering
  // ----------------------------------------------------------------
  void _filterFilms(Iterable<Film> films) {
    if (films.isEmpty) return;

    var temp = films.toList();

    // Exclude watched if _includeWatched == false
    if (!_includeWatched) {
      temp = temp.where((film) => film.isWatched == false).toList();
    }

    // Filter by genres
    if (_genresToFilter.isNotEmpty) {
      temp = temp.where((film) {
        // if includeMode == true, we keep films that contain ANY of the selected genres
        // if false, we keep films that do NOT contain ANY of the selected genres
        final filmHasAnyGenre = _genresToFilter.any((g) => film.genres.contains(g));
        return _genresFilterIncludeMode ? filmHasAnyGenre : !filmHasAnyGenre;
      }).toList();
    }

    // Filter by categories
    if (_categoriesToFilter.isNotEmpty) {
      temp = temp.where((film) {
        final filmHasAnyCategory =
            _categoriesToFilter.any((c) => film.categories.contains(c));
        return _categoriesFilterIncludeMode ? filmHasAnyCategory : !filmHasAnyCategory;
      }).toList();
    }

    setState(() {
      _selectedFilmIndex = null;
      _filteredFilms = temp;
    });

    _itemScrollController.jumpTo(index: 0);
  }
}