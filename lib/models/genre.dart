import 'package:film_randomizer/models/base/localizable.dart';

class Genre extends Localizable{
  Genre(super.id, super.localizationId);

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      json['_id'],
      json['localizationId'],
    );
  }
}