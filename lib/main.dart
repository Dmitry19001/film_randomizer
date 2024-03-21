import 'package:film_randomizer/providers/auth_provider.dart';
import 'package:film_randomizer/providers/category_provider.dart';
import 'package:film_randomizer/providers/film_provider.dart';
import 'package:film_randomizer/providers/genre_provider.dart';
import 'package:film_randomizer/providers/settings_provider.dart';
import 'package:film_randomizer/ui/screens/home_page.dart';
import 'package:film_randomizer/ui/screens/login_register_page.dart';
import 'package:film_randomizer/ui/themes/dark.dart';
import 'package:film_randomizer/ui/themes/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, value, child) { 
          return MyApp(authProvider: authProvider, settingsProvider: settingsProvider);
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final SettingsProvider settingsProvider;
  const MyApp({super.key, required this.authProvider, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FilmProvider()),
        ChangeNotifierProvider(create: (context) => GenreProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
      ],
      child: MaterialApp(
        locale: settingsProvider.language,
        onGenerateTitle: (BuildContext context) {
          final title = AppLocalizations.of(context)!.app_title;
          return title;
        },
        theme: settingsProvider.theme == AppTheme.dark ? DarkTheme.themeData : DefaultTheme.themeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _getInitialScreen(authProvider),
      ),
    );
  }

  Widget _getInitialScreen(AuthProvider auth) {
    return auth.isAuthenticated ? const HomePage() : const LoginRegisterPage();
  }
}

