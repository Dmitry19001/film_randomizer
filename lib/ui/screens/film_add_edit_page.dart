import 'package:film_randomizer/notifiers/category_notifier.dart';
import 'package:film_randomizer/notifiers/film_notifier.dart';
import 'package:film_randomizer/notifiers/genre_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:film_randomizer/models/category.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/models/genre.dart';

import 'package:film_randomizer/ui/widgets/multi_select_field.dart';

class FilmEditPage extends ConsumerStatefulWidget {
  final Film? film;
  const FilmEditPage({super.key, this.film});
  static String routeName = "/editFilm";

  @override
  ConsumerState<FilmEditPage> createState() => _FilmEditPageState();
}

class _FilmEditPageState extends ConsumerState<FilmEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late Film _film;

  @override
  void initState() {
    super.initState();
    // Clone or create a new film object
    _film = widget.film != null ? widget.film!.clone() : Film();

    // Kick off initial loading of genres/categories
    // We can't call ref.read(...) directly in initState(),
    // so we schedule it with addPostFrameCallback:
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(genreProvider.notifier).reloadGenres();
      await ref.read(categoryProvider.notifier).reloadCategories();
      setState(() {}); // Trigger a rebuild after loading
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = L10nAccessor.get(
      context,
      _film.id != null ? "edit_page" : "add_page",
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: _buildFilmForm(),
    );
  }

  Widget _buildFilmForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        children: [
          _buildTitleField(),
          _buildGenreField(),
          _buildCategoryField(),
          _buildWatchedSwitcher(),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // 1) Title
  // ----------------------------------------------------------------
  TextFormField _buildTitleField() {
    return TextFormField(
      initialValue: _film.title,
      decoration: InputDecoration(
        labelText: L10nAccessor.get(context, "title"),
      ),
      onSaved: (value) {
        _film.title = value ?? '';
      },
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Please enter a title' : null,
    );
  }

  // ----------------------------------------------------------------
  // 2) Genres
  // ----------------------------------------------------------------
  Widget _buildGenreField() {
    // Instead of Provider.of<GenreProvider>, we watch our genreProvider
    final genresAsync = ref.watch(genreProvider);

    // We handle loading/error/data with AsyncValue.when:
    return genresAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error loading genres: $err'),
      data: (genres) {
        return MultiSelectField<Genre>(
          context: context,
          items: genres.toList(),
          title: L10nAccessor.get(context, "genres"),
          buttonText: L10nAccessor.get(context, "select_genres"),
          buttonIconData: Icons.album,
          selectedItems: _film.genres.toList(),
          onConfirm: (values) {
            setState(() {
              _film.genres = values;
            });
          },
          onChipTap: (item) {
            setState(() {
              if (item != null) _film.genres.remove(item);
            });
          },
        );
      },
    );
  }

  // ----------------------------------------------------------------
  // 3) Categories
  // ----------------------------------------------------------------
  Widget _buildCategoryField() {
    // Instead of Provider.of<CategoryProvider>, we watch our categoryProvider
    final categoriesAsync = ref.watch(categoryProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error loading categories: $err'),
      data: (categories) {
        return MultiSelectField<Category>(
          context: context,
          items: categories.toList(),
          title: L10nAccessor.get(context, "categories"),
          buttonText: L10nAccessor.get(context, "select_categories"),
          buttonIconData: Icons.category,
          selectedItems: _film.categories.toList(),
          onConfirm: (values) {
            setState(() {
              _film.categories = values;
            });
          },
          onChipTap: (item) {
            setState(() {
              if (item != null) _film.categories.remove(item);
            });
          },
        );
      },
    );
  }

  // ----------------------------------------------------------------
  // 4) Watched Switch
  // ----------------------------------------------------------------
  SwitchListTile _buildWatchedSwitcher() {
    return SwitchListTile(
      title: Text(L10nAccessor.get(context, "is_watched")),
      enableFeedback: true,
      contentPadding: EdgeInsets.zero,
      value: _film.isWatched,
      onChanged: (bool value) {
        setState(() => _film.isWatched = value);
      },
    );
  }

  // ----------------------------------------------------------------
  // 5) Submit Button
  // ----------------------------------------------------------------
  ElevatedButton _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          _handleSubmit();
        }
      },
      child: _isLoading
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            )
          : Text(L10nAccessor.get(context, "submit")),
    );
  }

  // ----------------------------------------------------------------
  // Handling Submission
  // ----------------------------------------------------------------
  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    String message = '';
    bool success = true;

    try {
      // Instead of Provider.of<FilmProvider>, we access the Riverpod filmProvider
      final filmNotifier = ref.read(filmProvider.notifier);

      if (_film.id == null) {
        final result = await filmNotifier.createFilm(_film);
        message = mounted ? L10nAccessor.get(
          context,
          result ? "film_created_successfully" : "film_created_error",
        ) : '';
      } else {
        final result = await filmNotifier.updateFilm(_film);
        message = mounted ? L10nAccessor.get(
          context,
          result ? "film_updated_successfully" : "film_updated_error",
        ) : '';
      }
    } catch (e) {
      success = false;
      message = mounted ? L10nAccessor.get(context, "error_occurred") : e.toString();
    }

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(); // Go back to the previous screen
    }
    Fluttertoast.showToast(msg: message);

    setState(() => _isLoading = false);
  }
}
