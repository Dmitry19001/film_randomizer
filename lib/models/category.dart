import 'package:film_randomizer/models/base/localizable.dart';

class Category extends Localizable {
  @override
  final String id;

  @override
  final String localizationId;

  Category(this.id, this.localizationId);
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      json['_id'],
      json['localizationId'],
    );
  }
}