import 'package:film_randomizer/ui/screens/home_page.dart';
import 'package:film_randomizer/ui/themes/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) {
        final title = AppLocalizations.of(context)!.app_title;
        Logger().d("App title is: $title");
        return title;
      },
      theme: AppTheme.defaultTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MyHomePage(),
    );
  }
}
