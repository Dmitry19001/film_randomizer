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
    _film = widget.film.clone();
    _loadInitialData();
  }

  void _loadInitialData() async {
    await Provider.of<GenreProvider>(context, listen: false).loadGenres();
    await Provider.of<CategoryProvider>(context, listen: false).loadCategories();

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
    if (genreProvider.genres == null) return const Center(child: CircularProgressIndicator());
    return _buildMultiSelectField<Genre>(
      items: genreProvider.genres!.toList(),
      title: L10nAccessor.get(context, "genres"),
      buttonText: L10nAccessor.get(context, "select_genres"),
      selectedItems: _film.genres,
      onConfirm: (values) {
        setState(() {
          _film.genres = values;
        });
      }
    );
  }

  Widget _buildCategoryField() {
    final CategoryProvider categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.categories == null) return const Center(child: CircularProgressIndicator());
    return _buildMultiSelectField<Category>(
      items: categoryProvider.categories!.toList(),
      title: L10nAccessor.get(context, "categories"),
      buttonText: L10nAccessor.get(context, "select_categories"),
      selectedItems: _film.categories,
      onConfirm: (values) {
        setState(() {
          _film.categories = values;
        });
      }
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

        if (_film.id == null) {
          bool result = await filmProvider.createFilm(_film);
          message = L10nAccessor.get(context, result? "film_created_successfully" : "film_created_error");
        } else {
          bool result = await filmProvider.updateFilm(_film);
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
