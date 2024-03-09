import 'package:flutter/material.dart';
import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:film_randomizer/ui/screens/settings_page.dart'; // Ensure this is the correct path to your SettingsScreen.

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(L10nAccessor.get(context, 'app_title')), // Assuming L10nAccessor setup is correctly done.
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            // Navigate to the SettingsScreen when the settings button is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Provide a default preferred size for AppBar
}
