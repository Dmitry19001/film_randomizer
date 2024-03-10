import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:film_randomizer/models/base/localizable.dart';
import 'package:film_randomizer/models/category.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/providers/category_provider.dart';
import 'package:film_randomizer/providers/film_provider.dart';
import 'package:film_randomizer/providers/genre_provider.dart';
import 'package:film_randomizer/ui/themes/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

class FilmEditPage extends StatefulWidget {
  final Film film;
  const FilmEditPage({super.key, required this.film});

  @override
  State<FilmEditPage> createState() => _FilmEditPageState();
}

class _FilmEditPageState extends State<FilmEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final pageTitle = L10nAccessor.get(context, widget.film.id != null? "edit_page" : "add_page");

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: FutureBuilder(
        future: Future.wait([
          Provider.of<GenreProvider>(context, listen: false).loadGenres(),
          Provider.of<CategoryProvider>(context, listen: false).loadCategories(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          return _buildFilmForm();
        },
      ),
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
      initialValue: widget.film.title,
      decoration: InputDecoration(
        labelText: L10nAccessor.get(context, "title")
      ),
      onSaved: (value) => widget.film.title = value ?? '',
      validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
    );
}

  SwitchListTile _buildWatchedSwitcher() {
    return SwitchListTile(
      title: Text(L10nAccessor.get(context, "is_watched")),
      enableFeedback: true,
      contentPadding: EdgeInsets.zero,
      value: widget.film.isWatched,
      onChanged: (bool value) {
        setState(() => widget.film.isWatched = value);
      },
    );
  }

  Widget _buildGenreField() {
    final GenreProvider genreProvider = Provider.of<GenreProvider>(context, listen: false);
    return _buildMultiSelectField<Genre>(
      items: genreProvider.genres!.toList(),
      title: L10nAccessor.get(context, "genres"),
      buttonText: L10nAccessor.get(context, "select_genres"),
      selectedItems: widget.film.genres,
      onConfirm: (values) => widget.film.genres = values,
    );
  }

  Widget _buildCategoryField() {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    return _buildMultiSelectField<Category>(
      items: categoryProvider.categories!.toList(),
      title: L10nAccessor.get(context, "categories"),
      buttonText: L10nAccessor.get(context, "select_categories"),
      selectedItems: widget.film.categories,
      onConfirm: (values) => widget.film.categories = values,
    );
  }

  Widget _buildMultiSelectField<T>({
    required List<Localizable> items,
    required String title,
    required String buttonText,
    required Set<Localizable> selectedItems,
    required Function(Set<T>) onConfirm,
  }) {
    final List<MultiSelectItem<Localizable>> multiSelectItems = items
        .map((item) => MultiSelectItem<Localizable>(item, item.localizedName(context)))
        .toList();


    return MultiSelectBottomSheetField(
      initialChildSize: 0.4,
      listType: MultiSelectListType.CHIP,
      searchable: true,
      buttonText: Text(buttonText),
      title: Text(title),
      itemsTextStyle: Theme.of(context).customExtension.textStyle,
      items: multiSelectItems,
      onConfirm: (values) {
        onConfirm(Set.from(values.cast<T>()));
      },
      chipDisplay: MultiSelectChipDisplay(
        chipColor: Theme.of(context).customExtension.chipColor,
        textStyle: Theme.of(context).customExtension.textStyle,
        onTap: (item) {
          setState(() {
             if (item != null) selectedItems.remove(item);
          });
        },
      ),
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

        if (widget.film.id == null) {
          bool result = await filmProvider.createFilm(widget.film);
          message = L10nAccessor.get(context, result? "film_created_successfully" : "film_created_error");
        } else {
          bool result = await filmProvider.updateFilm(widget.film);
          message = L10nAccessor.get(context, result? "film_updated_successfully" : "film_updated_error");
        }
      } catch (e) {
        success = false;
        message = L10nAccessor.get(context, "error_occurred");
      }

      if (mounted) {
        if (success) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
        Fluttertoast.showToast(msg: message);
        setState(() => _isLoading = false);
      }
    }
  }

}
