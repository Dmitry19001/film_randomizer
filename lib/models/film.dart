import 'package:film_randomizer/models/genre.dart';
import 'package:film_randomizer/models/category.dart';

class Film {
  String? id;
  String? title;
  bool isWatched;
  Set<Genre> genres;
  Set<Category> categories;
  String? addedBy;
  String imageUrl;
  DateTime? createdAt;
  DateTime? updatedAt;

  Film({
    this.id,
    this.title,
    this.isWatched = false,
    List<Genre>? genres,
    List<Category>? categories,
    this.addedBy,
    this.imageUrl = "",
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

  factory Film.fromJson(Map<String, dynamic> json) {
    List<Genre> genres = json['genres'] != null
        ? List<Genre>.from(json['genres'].map((genreJson) => Genre.fromJson(genreJson)))
        : [];

    List<Category> categories = json['categories'] != null
        ? List<Category>.from(json['categories'].map((categoryJson) => Category.fromJson(categoryJson)))
        : [];

    return Film(
      id: json['_id'],
      title: json['title'],
      isWatched: json['isWatched'] ?? false,
      genres: genres,
      categories: categories,
      addedBy: json['addedBy'],
      imageUrl: json['imageUrl'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isWatched': isWatched,
      'genres': genres.map((genre) => genre.localizationId).toList(),
      'categories': categories.map((category) => category.localizationId).toList(),
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Film clone() {
    return Film(
      id: id,
      title: title,
      isWatched: isWatched,
      genres: genres.toList(),
      categories: categories.toList(),
      imageUrl: imageUrl,
      addedBy: addedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
