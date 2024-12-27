import 'dart:convert';
import 'package:film_randomizer/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class CategoryService {
  final Logger _logger = Logger();
  final String baseUrl;

  CategoryService(this.baseUrl);

  Future<List<Category>?> getCategories() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/categories"));
      if (response.statusCode == 200) {
        List<dynamic> categoryJsonList = json.decode(response.body);
        List<Category> categories = categoryJsonList.map((categoryJson) => Category.fromJson(categoryJson)).toList();
        return categories;
      } else {
        _logger.e('Failed to load categories: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error fetching categories: $e');
    }
    return null;
  }
}
