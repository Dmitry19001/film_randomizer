import 'dart:convert';

import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/models/category.dart';

class Film {
  String? id;
  String? title;
  bool isWatched;
  Set<Genre> genres;
  Set<Category> categories;
  DateTime? createdAt;
  DateTime? updatedAt;

  Film({
    this.id,
    this.title,
    this.isWatched = false,
    List<Genre>? genres,
    List<Category>? categories,
    this.createdAt,
    this.updatedAt,
  })  : genres = genres?.toSet() ?? {},
        categories = categories?.toSet() ?? {};

  void toggleWatchStatus() {
    isWatched = !isWatched;
  }

  void addGenre(Genre genre) {
    genres.add(genre);
  }

  void addCategory(Category category) {
    categories.add(category);
  }

  String toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'isWatched': isWatched,
      'genres': genres.map((genre) => genre.localizationId).toList(),
      'categories': categories.map((category) => category.localizationId).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

    return jsonEncode(data);
  }
}
