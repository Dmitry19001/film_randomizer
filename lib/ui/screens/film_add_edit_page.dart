import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:film_randomizer/models/category.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/providers/category_provider.dart';
import 'package:film_randomizer/providers/film_provider.dart';
import 'package:film_randomizer/providers/genre_provider.dart';
import 'package:film_randomizer/ui/widgets/multi_select_field.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class FilmEditPage extends StatefulWidget {
  final Film? film;
  const FilmEditPage({super.key, this.film});
  static String routeName = "/editFilm";

  @override
  State<FilmEditPage> createState() => _FilmEditPageState();
}

class _FilmEditPageState extends State<FilmEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late Film _film;

  @override
  void initState() {
    super.initState();
    _film = widget.film != null? widget.film!.clone() : Film();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final genreProvider = Provider.of<GenreProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    await genreProvider.loadGenres();
    await categoryProvider.loadCategories();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = L10nAccessor.get(context, _film.id != null? "edit_page" : "add_page");

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body:_buildFilmForm(),
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

  TextFormField _buildTitleField() {
    return TextFormField(
      initialValue: _film.title,
      decoration: InputDecoration(
        labelText: L10nAccessor.get(context, "title")
      ),
      onSaved: (value){
        setState(() {
          _film.title = value ?? '';
        });
      },
      validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
    );
}

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

  Widget _buildGenreField() {
    final GenreProvider genreProvider = Provider.of<GenreProvider>(context, listen: false);
    if (genreProvider.genres.isEmpty) return const Center(child: CircularProgressIndicator());
    return MultiSelectField<Genre>(
      context: context,
      items: genreProvider.genres.toList(),
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
  }

  Widget _buildCategoryField() {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.categories.isEmpty) return const Center(child: CircularProgressIndicator());
    return MultiSelectField<Category>(
      context: context,
      items: categoryProvider.categories.toList(),
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
  }


  ElevatedButton _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          _handleSubmit(context);
        }
      },
      child: _isLoading
          ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
          : Text(L10nAccessor.get(context, "submit")),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      String? message;
      bool success = true;

      try {
        final filmProvider = Provider.of<FilmProvider>(context, listen: false);

        if (_film.id == null) {
          bool result = await filmProvider.createFilm(_film);

          if (!context.mounted) return;

          message = L10nAccessor.get(context, result? "film_created_successfully" : "film_created_error");
        } else {
          bool result = await filmProvider.updateFilm(_film);

          if (!context.mounted) return;

          message = L10nAccessor.get(context, result? "film_updated_successfully" : "film_updated_error");
        }
      } catch (e) {
        success = false;
        message = L10nAccessor.get(context, "error_occurred");
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
        }
        Fluttertoast.showToast(msg: message);
        setState(() => _isLoading = false);
      }
    }
  }

}
