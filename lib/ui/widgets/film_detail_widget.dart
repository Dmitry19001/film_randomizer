import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:film_randomizer/providers/film_provider.dart';
import 'package:film_randomizer/ui/screens/film_add_edit_page.dart';
import 'package:film_randomizer/ui/widgets/delete_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';


class FilmDetailWidget extends StatefulWidget {
  final Film film;
  final bool showAdditionalControls;

  const FilmDetailWidget({
    super.key,
    required this.film,
    this.showAdditionalControls = false
  });

  @override
  State<FilmDetailWidget> createState() => _FilmDetailWidgetState();
}


class _FilmDetailWidgetState extends State<FilmDetailWidget> {
  bool _isOverlayVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _toggleOverlay();
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildWatchedIndicator(),
            _buildCardLayout(context),
            if (_isOverlayVisible) _buildOverlay(context),
          ]
        )
      )
    );
  }

  Widget _buildCardLayout(BuildContext context) {
    return Row(
      children: [
        if (widget.film.imageUrl.isNotEmpty) _buildImage(context),
        _buildCardContent(context),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Image.network(
        widget.film.imageUrl,
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Expanded(
      flex: 7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        widget.film.genres.map((genre) => genre.localizedName(context)).join(', '),
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
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        widget.film.categories.map((category) => category.localizedName(context)).join(', '),
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
          color: widget.film.isWatched? Colors.green : Colors.redAccent,
          borderRadius: const BorderRadius.all(Radius.circular(25))
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => _toggleOverlay(),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Wrap(
              // mainAxisSize: MainAxisSize.min,
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
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor;
        }),
      ),
      onPressed: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FilmEditPage(film: widget.film,)),
        ),
        _toggleOverlay()
      },
      icon: const Icon(Icons.edit_document),
      tooltip: L10nAccessor.get(context, "edit"),
    );
  }

  IconButton _buildDeleteButton(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return Colors.red;
        }),
      ),
      onPressed: () async {
        await _handleDelete(context);
      },
      icon: const Icon(Icons.delete),
      tooltip: L10nAccessor.get(context, "delete"),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final FilmProvider filmProvider = Provider.of<FilmProvider>(context, listen: false);

    _toggleOverlay();
    
    final bool confirmDelete = await showDeleteConfirmationDialog(context);
    
    if (!confirmDelete || !context.mounted) return;

    final result = await filmProvider.deleteFilm(widget.film);
    
    if (!context.mounted) return;

    final message = L10nAccessor.get(context, result ? "film_delete_success" : "film_delete_error");

    Fluttertoast.showToast(msg: message);
  }

  Widget _buildAdditionalControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          // mainAxisAlignment: MainAxisAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if(!widget.film.isWatched) _buildMarkAsWatchedButton(),
            _buildOkButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildMarkAsWatchedButton() {
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

  Widget _buildOkButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(L10nAccessor.get(context, "ok")),
    );
  }

  void _toggleOverlay() {
    if (widget.showAdditionalControls) return;
    
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  Future<void> _handleSave(BuildContext context) async {
    final filmProvider = Provider.of<FilmProvider>(context, listen: false);

    await filmProvider.updateFilm(widget.film);

    if (!context.mounted) return;

    final message = L10nAccessor.get(context, "film_marked_as_watched");

    Fluttertoast.showToast(msg: message);

    Navigator.of(context).pop();
  }
}
