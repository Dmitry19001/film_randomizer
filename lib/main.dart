import 'package:film_randomizer/providers/category_provider.dart';
import 'package:film_randomizer/providers/film_provider.dart';
import 'package:film_randomizer/providers/genre_provider.dart';
import 'package:film_randomizer/providers/settings_provider.dart';
import 'package:film_randomizer/ui/screens/home_page.dart';
import 'package:film_randomizer/ui/themes/dark.dart';
import 'package:film_randomizer/ui/themes/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Make sure prefs are initialized
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => settingsProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MultiProvider(
      providers: _buildProviders(context),
      child: MaterialApp(
        locale: settingsProvider.language,
        onGenerateTitle: (BuildContext context) {
          final title = AppLocalizations.of(context)!.app_title;
          Logger().d("App title is: $title");
          return title;
        },
        theme: settingsProvider.theme == AppTheme.dark? DarkTheme.themeData : DefaultTheme.themeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MyHomePage(),
      ),
    );
  }

  List<SingleChildWidget> _buildProviders(context) {
    return [
      ChangeNotifierProvider(create: (context) => FilmProvider()),
      ChangeNotifierProvider(create: (context) => GenreProvider()),
      ChangeNotifierProvider(create: (context) => CategoryProvider()),
    ];
  }
}
