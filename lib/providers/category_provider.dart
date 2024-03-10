import 'package:film_randomizer/models/category.dart';
import 'package:film_randomizer/services/category_service.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category>? _categories;

  Iterable<Category>? get categories => _categories;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _categories = await _categoryService.getCategories();
    notifyListeners();
  }
}
