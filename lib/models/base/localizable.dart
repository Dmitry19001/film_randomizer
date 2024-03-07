import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:flutter/material.dart';

abstract class Localizable {
  String get localizationId;

  String localizedName(BuildContext context) {
    return L10nAccessor.get(context, localizationId) ?? localizationId;
  }

  @override
  String toString() {
    return localizationId;
  }
}
