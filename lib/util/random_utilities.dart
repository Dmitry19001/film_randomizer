import 'package:film_randomizer/models/film.dart';

Iterable<Film> randomizeSize(Iterable<Film> items, {int minCount = 50}) {
  final List<Film> result = [];
  final List<Film> itemsList = items.toList();

  // Ensure the list is shuffled at least once
  itemsList.shuffle();
  result.addAll(itemsList);

  // Calculate how many times we need to repeat the list to reach minCount
  int multiply = (minCount / itemsList.length).ceil();

  for (int x = 1; x < multiply; x++) {
    itemsList.shuffle();
    result.addAll(itemsList);
  }

  return result;
}
