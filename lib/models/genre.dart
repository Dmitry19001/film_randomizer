import 'package:film_randomizer/models/base/localizable.dart';

class Genre extends Localizable{
  @override
  final String id;

  @override
  final String localizationId;

  Genre(this.id, this.localizationId);
}