import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:flutter/material.dart';

abstract class Localizable {
  final String id;
  final String localizationId;

  Localizable(this.id, this.localizationId);

  String localizedName(BuildContext context) {
    return L10nAccessor.get(context, localizationId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Localizable &&
      other.id == id &&
      other.localizationId == localizationId;
  }

  @override
  int get hashCode => id.hashCode ^ localizationId.hashCode;

  @override
  String toString() {
    return localizationId;
  }
}
