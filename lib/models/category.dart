import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Category {
  final String localizationId;

  Category(this.localizationId);

  // String localizedName(BuildContext context) {
  //   // Assuming S is your generated localization class
  //   final localizedName = AppLocalizations.of(context).getString(localizationId);
  //   // Use localizationId as a fallback if localizedName is null or empty
  //   return localizedName.isNotEmpty ? localizedName : localizationId;
  // }
}