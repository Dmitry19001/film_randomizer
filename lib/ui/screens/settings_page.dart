import 'package:film_randomizer/providers/settings_provider.dart';
import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  static String routeName = "/settings";


  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nAccessor.get(context, "settings_page")),
      ),
      body: ListView(
        children: [
          _buildLanguageDropDown(context, settingsProvider),
          _buildShowWatchedSwitcher(settingsProvider, context),
          _buildThemeSelector(settingsProvider, context),
          _buildVersionInfo(context),
        ],
      ),
    );
  }

  Widget _buildLanguageDropDown(BuildContext context, SettingsProvider provider) {
    const supportedLocales  = AppLocalizations.supportedLocales;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownMenu<Locale>(
        enableSearch: false,
        // width: MediaQuery.of(context).size.width - 16,
        expandedInsets: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        requestFocusOnTap: false,
        // leadingIcon: const Icon(Icons.language),
        label: Text(L10nAccessor.get(context, 'language')),
        textStyle: Theme.of(context).textTheme.bodyMedium,
        initialSelection: provider.language,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
        ),
        onSelected: (Locale? locale) {
          if (locale != null) {
            provider.setLanguage(locale);
          }
        },
        dropdownMenuEntries: supportedLocales.map<DropdownMenuEntry<Locale>>((Locale locale) {
            return DropdownMenuEntry<Locale>(
              value: locale,
              label: locale.toLanguageTag().toUpperCase(),
            );
          }).toList(),
      ),
    );
  }

  Widget _buildShowWatchedSwitcher(SettingsProvider provider, BuildContext context) {
    return SwitchListTile(
      title: Text(L10nAccessor.get(context, "show_watched")),
      value: provider.showWatched,
      onChanged: (bool newValue) {
        provider.setShowWatched(newValue);
      },
    );
  }

  Widget _buildThemeSelector(SettingsProvider provider, BuildContext context) {
    return ListTile(
      title: Text(L10nAccessor.get(context, 'theme')),
      trailing: Switch(
        value: provider.theme == AppTheme.dark,
        onChanged: (bool newValue) {
          provider.toggleTheme(); 
        },
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.hasData) {
          return ListTile(
            title: Text(L10nAccessor.get(context, "app_version")),
            subtitle: Text(snapshot.data!.version),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
