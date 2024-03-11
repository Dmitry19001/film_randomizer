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
          _buildLanguageSelector(settingsProvider, context),
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
