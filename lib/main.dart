import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:film_randomizer/notifiers/settings_notifier.dart';
import 'package:film_randomizer/states/settings_state.dart';
import 'package:film_randomizer/notifiers/auth_notifier.dart';
import 'package:film_randomizer/states/auth_state.dart';

import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:film_randomizer/ui/screens/home_page.dart';
import 'package:film_randomizer/ui/screens/login_register_page.dart';
import 'package:film_randomizer/ui/themes/dark.dart';
import 'package:film_randomizer/ui/themes/default.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) Watch the settingsProvider (AsyncValue<SettingsState>)
    final settingsAsync = ref.watch(settingsProvider);

    // 2) Watch the authProvider (AsyncValue<AuthState>)
    final authAsync = ref.watch(authProvider);

    // If either settings or auth is loading, show a loading screen
    if (settingsAsync.isLoading || authAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // If either settings or auth has an error, show an error screen
    if (settingsAsync.hasError) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error loading settings: ${settingsAsync.error}'),
          ),
        ),
      );
    }
    if (authAsync.hasError) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error checking auth: ${authAsync.error}'),
          ),
        ),
      );
    }

    // At this point, we know both have data:
    final settings = settingsAsync.value!;
    final authState = authAsync.value!;

    return MaterialApp(
      locale: settings.language,
      onGenerateTitle: (BuildContext context) {
        final title = L10nAccessor.get(context, "app_title");
        return title;
      },
      theme: settings.theme == AppTheme.dark
          ? DarkTheme.themeData
          : DefaultTheme.themeData,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _getInitialScreen(authState), // see below
      onNavigationNotification: (notification) {
        // If you still need this line
        return notification.canHandlePop;
      },
    );
  }

  Widget _getInitialScreen(AuthState authState) {
    // If the user is authenticated, go to HomePage; otherwise, show Login
    if (authState.isAuthenticated) {
      return const HomePage();
    } else {
      return const LoginRegisterPage();
    }
  }
}
