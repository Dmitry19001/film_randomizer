import 'package:film_randomizer/notifiers/settings_notifier.dart';
import 'package:film_randomizer/states/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  static String routeName = "/settings";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our async SettingsState
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nAccessor.get(context, "settings_page")),
      ),
      // Because settingsProvider is AsyncNotifier, we handle loading/error/data:
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading settings: $err'),
        ),
        data: (settings) {
          // `settings` is our SettingsState (language, showWatched, theme).
          return ListView(
            children: [
              _buildLanguageDropDown(context, ref, settings),
              _buildShowWatchedSwitcher(context, ref, settings),
              _buildThemeSelector(context, ref, settings),
              _buildVersionInfo(context),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------------
  // 2. Updated Helper Methods
  //    Instead of passing around a SettingsProvider, we just pass
  //    the current SettingsState + a WidgetRef to do updates.
  // ------------------------------------------------------------------

  Widget _buildLanguageDropDown(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    const supportedLocales  = AppLocalizations.supportedLocales;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownMenu<Locale>(
        enableSearch: false,
        expandedInsets: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        requestFocusOnTap: false,
        label: Text(L10nAccessor.get(context, 'language')),
        textStyle: Theme.of(context).textTheme.bodyMedium,
        initialSelection: settings.language,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
        ),
        onSelected: (Locale? locale) {
          if (locale != null) {
            // Instead of settingsProvider.setLanguage(...),
            // we call our notifier method:
            ref.read(settingsProvider.notifier).setLanguage(locale);
          }
        },
        dropdownMenuEntries: supportedLocales.map<DropdownMenuEntry<Locale>>(
          (Locale locale) {
            return DropdownMenuEntry<Locale>(
              value: locale,
              label: locale.toLanguageTag().toUpperCase(),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildShowWatchedSwitcher(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    return SwitchListTile(
      title: Text(L10nAccessor.get(context, "show_watched")),
      value: settings.showWatched,
      onChanged: (bool newValue) {
        // Instead of provider.setShowWatched(...),
        // call ref.read(settingsProvider.notifier).setShowWatched(...)
        ref.read(settingsProvider.notifier).setShowWatched(newValue);
      },
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    return ListTile(
      title: Text(L10nAccessor.get(context, 'theme')),
      trailing: Switch(
        value: settings.theme == AppTheme.dark,
        onChanged: (bool newValue) {
          // Instead of provider.toggleTheme(),
          // use our notifier:
          ref.read(settingsProvider.notifier).toggleTheme();
        },
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    // We can keep using FutureBuilder for package info
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            title: Text(L10nAccessor.get(context, "app_version")),
            subtitle: Text(snapshot.data!.version),
          );
        } else {
          return Container(); // or a progress spinner
        }
      },
    );
  }
}
