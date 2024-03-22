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

  const FilmDetailWidget({super.key, required this.film});

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
            _buildCardContent(context),
            if (_isOverlayVisible) _buildOverlay(context),
          ]
        )
      )
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.film.title ?? L10nAccessor.get(context, "missing_title"),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Text(
            "${L10nAccessor.get(context, "genres")}: ${widget.film.genres.map((genre) => genre.localizedName(context)).join(', ')}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),
          Text(
            "${L10nAccessor.get(context, "categories")}: ${widget.film.categories.map((category) => category.localizedName(context)).join(', ')}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),
          Text(
            "${widget.film.addedBy}",
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.end,
          ),
        ],
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

  ElevatedButton _buildEditButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FilmEditPage(film: widget.film,)),
        ),
        _toggleOverlay()
      },
      icon: const Icon(Icons.edit_document),
      label: Text(L10nAccessor.get(context, "edit")),
    );
  }

  IconButton _buildDeleteButton(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
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
    _toggleOverlay();
    
    final bool confirmDelete = await showDeleteConfirmationDialog(context);
    
    if (!confirmDelete) return;

    final result = await Provider.of<FilmProvider>(context, listen: false).deleteFilm(widget.film);
    
    if (!mounted) return;

    final message = L10nAccessor.get(context, result ? "film_delete_success" : "film_delete_error");

    Fluttertoast.showToast(msg: message);
  }

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }
}
