import 'package:film_randomizer/providers/settings_provider.dart';
import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nAccessor.get(context, "settings_page")),
      ),
      body: ListView(
        children: [
          //_buildLanguageSelector(settingsProvider, context),
          _buildLanguageDropDown(context, settingsProvider),
          _buildShowWatchedSwitcher(settingsProvider, context),
          _buildThemeSelector(settingsProvider, context),
          _buildVersionInfo(context),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(SettingsProvider provider, BuildContext context) {
    const supportedLocales  = AppLocalizations.supportedLocales;
    
    return ListTile(
      title: Text(L10nAccessor.get(context, 'language')),
      trailing: DropdownButton<Locale>(
        value: provider.language,
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: (Locale? newValue) {
          if (newValue != null) {
            provider.setLanguage(newValue);
          }
        },
        items: supportedLocales.map<DropdownMenuItem<Locale>>((Locale locale) {
          return DropdownMenuItem<Locale>(
            value: locale,
            child: Text(locale.toLanguageTag().toUpperCase()),
          );
        }).toList(),
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
