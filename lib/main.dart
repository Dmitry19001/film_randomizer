import 'package:film_randomizer/providers/auth_provider.dart';
import 'package:film_randomizer/providers/category_provider.dart';
import 'package:film_randomizer/providers/film_provider.dart';
import 'package:film_randomizer/providers/genre_provider.dart';
import 'package:film_randomizer/providers/settings_provider.dart';
import 'package:film_randomizer/ui/screens/film_add_edit_page.dart';
import 'package:film_randomizer/ui/screens/home_page.dart';
import 'package:film_randomizer/ui/screens/login_register_page.dart';
import 'package:film_randomizer/ui/screens/randomizer_page.dart';
import 'package:film_randomizer/ui/screens/settings_page.dart';
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

class MyApp extends StatefulWidget {
  final AuthProvider authProvider;
  final SettingsProvider settingsProvider;
  const MyApp({super.key, required this.authProvider, required this.settingsProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider.value(value: widget.settingsProvider),
        ChangeNotifierProvider(create: (context) => FilmProvider()),
        ChangeNotifierProvider(create: (context) => GenreProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
      ],
      child: MaterialApp(
        locale: widget.settingsProvider.language,
        onGenerateTitle: (BuildContext context) {
          final title = AppLocalizations.of(context)!.app_title;
          return title;
        },
        theme: widget.settingsProvider.theme == AppTheme.dark ? DarkTheme.themeData : DefaultTheme.themeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _getInitialScreen(widget.authProvider),
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Widget _getInitialScreen(AuthProvider auth) {
    return auth.isAuthenticated ? const HomePage() : const LoginRegisterPage();
  }

  Route? _onGenerateRoute(RouteSettings settings) {
    if (!widget.authProvider.isAuthenticated) {
      return MaterialPageRoute(builder: (ctx) => const LoginRegisterPage());
    }

    var routeBuilders = _buildRoutes();

    WidgetBuilder? builder = routeBuilders[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }

    return MaterialPageRoute(builder: (ctx) => const HomePage());
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      HomePage.routeName: (ctx) => const HomePage(),
      SettingsScreen.routeName: (ctx) => const SettingsScreen(),
      FilmEditPage.routeName: (ctx) => const FilmEditPage(),
      LoginRegisterPage.routeName: (ctx) => const LoginRegisterPage(),
      RandomizeScreen.routeName: (ctx) => const RandomizeScreen(),
    };
  }
}

