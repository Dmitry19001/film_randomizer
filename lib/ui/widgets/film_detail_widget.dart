import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:flutter/material.dart';
import 'package:film_randomizer/models/film.dart';


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
        setState(() {
          _isOverlayVisible = !_isOverlayVisible;
        });
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
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
            "${L10nAccessor.get(context, "genres")}: ${widget.film.genres.map((genre) => genre.toString()).join(', ')}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),
          Text(
            "${L10nAccessor.get(context, "categories")}: ${widget.film.categories.map((category) => category.toString()).join(', ')}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),
          Text(
            "Added by: ${widget.film.addedBy}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _isOverlayVisible = false),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Overlay Controls",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _isOverlayVisible = false),
                  child: Text('Close'),
                ),
                // Add more controls as needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
