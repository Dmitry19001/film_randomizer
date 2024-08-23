import 'package:film_randomizer/models/category.dart';
import 'package:film_randomizer/services/category_service.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final List<Category> _categories = [];

  Iterable<Category> get categories => _categories;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final fetchedCategories = await _categoryService.getCategories();

    if (fetchedCategories == null) return;

    _categories.clear();
    _categories.addAll(fetchedCategories);

    notifyListeners();
  }
}
