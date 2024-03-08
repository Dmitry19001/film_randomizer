import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:flutter/material.dart';
import 'package:film_randomizer/models/film.dart';

class FilmDetailWidget extends StatelessWidget {
  final Film film;

  const FilmDetailWidget({super.key, required this.film});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              film.title ?? L10nAccessor.get(context, "missing_title"),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              "${L10nAccessor.get(context, "genres")}: ${film.genres.map((genre) => genre).join(', ')}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              "${L10nAccessor.get(context, "categories")}: ${film.categories.map((category) => ScriptCategory).join(', ')}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              "Added by: ${film.addedBy}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
