import 'package:film_randomizer/config/config.dart';
import 'package:film_randomizer/notifiers/film_notifier.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // NEW import for Riverpod

import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/ui/screens/film_add_edit_page.dart';
import 'package:film_randomizer/ui/widgets/delete_confirmation_dialog.dart';

class FilmDetailWidget extends ConsumerStatefulWidget {
  final Film film;
  final bool showAdditionalControls;

  const FilmDetailWidget({
    super.key,
    required this.film,
    this.showAdditionalControls = false,
  });

  @override
  ConsumerState<FilmDetailWidget> createState() => _FilmDetailWidgetState();
}

class _FilmDetailWidgetState extends ConsumerState<FilmDetailWidget> {
  bool _isOverlayVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _toggleOverlay,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildWatchedIndicator(),
            _buildCardLayout(context),
            if (_isOverlayVisible) _buildOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCardLayout(BuildContext context) {
    return Row(
      children: [
        if (widget.film.imageUrl.isNotEmpty && showFilmPicture) _buildImage(context),
        _buildCardContent(context),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Image.network(widget.film.imageUrl),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title, genres, categories, addedBy
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.film.title ?? L10nAccessor.get(context, "missing_title"),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      Icons.album,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        widget.film.genres
                            .map((genre) => genre.localizedName(context))
                            .join(', '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: Theme.of(context).colorScheme.primary.withValues( alpha: 0.5 ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        widget.film.categories
                            .map((category) => category.localizedName(context))
                            .join(', '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  "${widget.film.addedBy}",
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
            // Additional controls (if any)
            if (widget.showAdditionalControls) _buildAdditionalControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchedIndicator() {
    return Positioned(
      right: -25,
      top: -25,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: widget.film.isWatched ? Colors.green : Colors.redAccent,
          borderRadius: const BorderRadius.all(Radius.circular(25)),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleOverlay,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Wrap(
              spacing: 10,
              children: [
                _buildDeleteButton(context),
                _buildEditButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconButton _buildEditButton(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FilmEditPage(film: widget.film)),
        );
        _toggleOverlay();
      },
      icon: const Icon(Icons.edit_document),
      tooltip: L10nAccessor.get(context, "edit"),
    );
  }

  IconButton _buildDeleteButton(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.red),
      ),
      onPressed: () async {
        await _handleDelete(context);
      },
      icon: const Icon(Icons.delete),
      tooltip: L10nAccessor.get(context, "delete"),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    // Use our Riverpod filmProvider instead of the old Provider-based approach
    final filmNotifier = ref.read(filmProvider.notifier);

    _toggleOverlay();

    final bool confirmDelete = await showDeleteConfirmationDialog(context);
    if (!confirmDelete || !mounted) return;

    // Delete the film
    final result = await filmNotifier.deleteFilm(widget.film);
    if (!context.mounted) return;

    final message = L10nAccessor.get(
      context,
      result ? "film_delete_success" : "film_delete_error",
    );
    Fluttertoast.showToast(msg: message);
  }

  Widget _buildAdditionalControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (!widget.film.isWatched) _buildMarkAsWatchedButton(context),
            _buildOkButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildMarkAsWatchedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          widget.film.isWatched = !widget.film.isWatched;
        });
        await _handleSave(context);
      },
      child: Text(L10nAccessor.get(context, "is_watched")),
    );
  }

  Widget _buildOkButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(L10nAccessor.get(context, "ok")),
    );
  }

  void _toggleOverlay() {
    // If the user has showAdditionalControls, we don't toggle overlay
    if (widget.showAdditionalControls) return;

    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  Future<void> _handleSave(BuildContext context) async {
    final filmNotifier = ref.read(filmProvider.notifier);

    // Update the film
    await filmNotifier.updateFilm(widget.film);

    if (!context.mounted) return;

    final message = L10nAccessor.get(context, "film_marked_as_watched");
    Fluttertoast.showToast(msg: message);

    Navigator.of(context).pop();
  }
}
