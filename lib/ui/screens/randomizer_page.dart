import 'dart:async';
import 'dart:math';
import 'package:film_randomizer/models/base/localizable.dart';
import 'package:film_randomizer/models/category.dart';
import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/providers/category_provider.dart';
import 'package:film_randomizer/providers/genre_provider.dart';
import 'package:film_randomizer/ui/widgets/film_detail_widget.dart';
import 'package:film_randomizer/ui/widgets/multi_select_field.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/util/random_utilities.dart';
import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RandomizeScreen extends StatefulWidget {
  final Iterable<Film>? films;

  const RandomizeScreen({super.key, this.films});

  static String routeName = "/randomizer";

  @override
  State<RandomizeScreen> createState() => _RandomizeScreenState();
}

class _RandomizeScreenState extends State<RandomizeScreen> with SingleTickerProviderStateMixin {
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

  bool _includeWathced = false;
  bool _genresFilterIncludeMode = true;
  bool _categoriesFilterIncludeMode = true;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final genreProvider = Provider.of<GenreProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    await genreProvider.loadGenres();
    await categoryProvider.loadCategories();
     
    setState(() {
      _genres = genreProvider.genres;
      _categories = categoryProvider.categories;
      _films = widget.films ?? [];
    });

    _filterFilms(_films);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.films == null || widget.films!.isEmpty) {
      Fluttertoast.showToast(msg: L10nAccessor.get(context, "missing_films"));
      Navigator.of(context).pop();
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

  Widget _buildFilterControls() {
    return Expanded(
      flex: 5,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              CheckboxMenuButton(
                value: _includeWathced,
                onChanged: (include) {
                  setState(
                  () {
                    _includeWathced = include!;
                  });
                  _filterFilms(_films);
                },
                child: Text(
                  L10nAccessor.get(context, "include_watched"),
                ),
              ),
              ... _buildMultiSelectFields(),
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
          toggleIncludeMode: () => setState(() => _genresFilterIncludeMode = !_genresFilterIncludeMode),
          clearSelectedItems: () {
            setState(() {
              _genresToFilter = [];
            });
            _filterFilms(_films);
          },
          multiselect: MultiSelectField<Genre>(
            context: context,
            items: _genres.toList(),
            title: L10nAccessor.get(context, "genres"),
            buttonText: L10nAccessor.get(context, "select_genres"),
            selectedItems: _genresToFilter,
            onConfirm: (items) {
              setState(() {
                _genresToFilter = items.toList();
              });
              _filterFilms(_films);
            },
            onChipTap: (item) {
              setState(() {
                _genresToFilter.remove(item);
                _genresToFilter = _genresToFilter.toList(); //Fixing chip not removing bug
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
          toggleIncludeMode: () => setState(() => _categoriesFilterIncludeMode = !_categoriesFilterIncludeMode),
          clearSelectedItems: () {
            setState(() {
              _categoriesToFilter = [];
            });
            _filterFilms(_films);
          },
          multiselect: MultiSelectField<Category>(
            context: context,
            items: _categories.toList(),
            title: L10nAccessor.get(context, "categories"),
            buttonText: L10nAccessor.get(context, "select_categories"),
            selectedItems: _categoriesToFilter,
            onConfirm: (items) {
              setState(() {
                _categoriesToFilter = items.toList();
              });
              _filterFilms(_films);
            },
            onChipTap: (item) {
              setState(() {
                _categoriesToFilter.remove(item);
                _categoriesToFilter = _categoriesToFilter.toList(); //Fixing chip not removing bug
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
        Expanded(
          child: multiselect,
        ),
        if (selectedItems.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearSelectedItems,
            color: Colors.red,
          ),
      ],
    );
  }

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
              Film film = _filteredFilms.elementAt(index);
              return _buildFilmListEntry(index, film);
            } else {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
              );
            }
          },
        ),
        _buildOverlay(context),
      ],
    );
  }

  Container _buildFilmListEntry(int index, Film film) {
    bool isSelected = index == _selectedFilmIndex;
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
        film.title!,
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

  Widget _buildRandomizeButton() {
    return FloatingActionButton(
      child: const Icon(Icons.shuffle),
      onPressed: () {
        _handleRandomize();
      },
    );
  }

  void _handleRandomize() {
    _itemScrollController.jumpTo(index: 0);

    _filterFilms(_films);

    setState(() {
      _filteredFilms = randomizeSize(_filteredFilms);
    });

    _selectedFilmIndex = Random().nextInt(_filteredFilms.length);
    if (_selectedFilmIndex! < (_filteredFilms.length / 2).ceil() ) {
      // Value should be always outside of 1/2 of the list, minimal repeats of films are 3 times
      // This makes the rolling animation not too slow
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

  void _showFilmDetails() {
    showGeneralDialog(
      context: context,

      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child){
        return ScaleTransition(
          scale: Tween<double>(begin: 0.1, end: 1.0).animate(animation),
          child: SafeArea(
            child: FilmDetailWidget(
              film: _filteredFilms.elementAt(_selectedFilmIndex!),
              showAdditionalControls: true
            ),
          ),
        );
      },
    );
  }
  
  void _filterFilms(Iterable<Film> films) {
    if (films.isEmpty) return;

    List<Film> temp = films.toList();

    // filtering out films that are watched
    if (!_includeWathced){
      temp = temp.where((film) => film.isWatched == false).toList();
    }

    // filtering by genres
    if (_genresToFilter.isNotEmpty) {
      temp = temp.where(
        (film) => _genresToFilter.any(
          (genre) => _genresFilterIncludeMode ?
            film.genres.contains(genre) // include
            : !film.genres.contains(genre) // exclude
        )
      ).toList();
    }

    // filtering by categories
    if (_categoriesToFilter.isNotEmpty) {
      temp = temp.where(
        (film) => _categoriesToFilter.any(
          (category) => _categoriesFilterIncludeMode ?
            film.categories.contains(category) // include
            : !film.categories.contains(category) // exclude
        )
      ).toList();
    }

    setState(() {
      _selectedFilmIndex = null;
      _filteredFilms = temp;
    });

    _itemScrollController.jumpTo(index: 0);
  }
}