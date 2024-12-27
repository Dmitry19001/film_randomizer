import 'dart:async';
import 'package:film_randomizer/models/category.dart';
import 'package:film_randomizer/notifiers/backend_ip_notifier.dart';
import 'package:film_randomizer/services/category_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Our Riverpod provider for the category list.
/// In other words, `ref.watch(categoryProvider)` gives you an `AsyncValue<List<Category>>`.
final categoryProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(CategoryNotifier.new);

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  @override
  FutureOr<List<Category>> build() async {
    // Called once when the provider is first read.
    // We'll load the categories from the server here.
    final categories = await _loadCategories();
    // If loading fails, you could return an empty list or throw an error
    return categories ?? <Category>[];
  }
  
  Future<List<Category>?>? _loadCategories() async {
    final service = _createCategoryService();
    return await service.getCategories();
  }

    /// Reloads the list of categories from the server and updates [state].
  Future<void> reloadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _loadCategories();
      if (categories == null) {
        // If null, treat as error
        state = const AsyncValue.error('Failed to load categories', StackTrace.empty);
      } else {
        state = AsyncValue.data(categories);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }


  /// Helper method to create a CategoryService with the current baseUrl
  CategoryService _createCategoryService() {
    final ipState = ref.read(backendIPProvider).valueOrNull;
    final baseUrl = ipState?.apiBaseUrl ?? 'http://localhost:3002/api';

    return CategoryService(baseUrl);
  }

}