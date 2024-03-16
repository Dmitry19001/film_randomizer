import 'package:flutter/material.dart';
import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:film_randomizer/ui/screens/settings_page.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const MainAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final String fallBackTitle = L10nAccessor.get(context, 'app_title');

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(title ?? fallBackTitle),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
