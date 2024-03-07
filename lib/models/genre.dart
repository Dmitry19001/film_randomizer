import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Map<String, Function(BuildContext)> localizedStringGetters = {
  'genre_action': (context) => AppLocalizations.of(context)!.genre_action,
  'genre_comedy': (context) => AppLocalizations.of(context)!.genre_comedy,
  'genre_drama': (context) => AppLocalizations.of(context)!.genre_drama,
  'genre_thriller': (context) => AppLocalizations.of(context)!.genre_thriller,
  'genre_documentary': (context) => AppLocalizations.of(context)!.genre_documentary,
  'genre_musical': (context) => AppLocalizations.of(context)!.genre_musical,
  'genre_romance': (context) => AppLocalizations.of(context)!.genre_romance,
  'genre_scifi': (context) => AppLocalizations.of(context)!.genre_scifi,
  'genre_crime': (context) => AppLocalizations.of(context)!.genre_crime,
  'genre_fantasy': (context) => AppLocalizations.of(context)!.genre_fantasy,
  'genre_fiction': (context) => AppLocalizations.of(context)!.genre_fiction,
  'genre_detective': (context) => AppLocalizations.of(context)!.genre_detective,
};

class Genre {
  final String localizationId;

  Genre(this.localizationId);

  String localizedName(BuildContext context) {
    var getter = localizedStringGetters[localizationId];
    if (getter != null) {
      return getter(context);
    } else {
      return localizationId;
    }
  }

  @override
  String toString() {
    return localizationId;
  }
}