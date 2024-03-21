import 'package:film_randomizer/models/base/localizable.dart';

class Category extends Localizable {
  Category(super.id, super.localizationId);
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      json['_id'],
      json['localizationId'],
    );
  }
}