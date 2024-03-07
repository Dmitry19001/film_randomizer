import 'package:film_randomizer/models/base/localizable.dart';

class Category extends Localizable {
  @override // Correctly annotating the overridden member
  final String localizationId;

  Category(this.localizationId);
}