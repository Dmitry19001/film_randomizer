import 'package:film_randomizer/ui/screens/randomizer_page.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final VoidCallback? onSync;

  const CustomBottomNavigation({super.key, this.onSync});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 50,
      notchMargin: 0,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildSyncButton(context),
          _buildRandomizeButton(context),
        ],
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    return Expanded(
      child: IconButton(
        icon: const Icon(Icons.sync),
        onPressed: () {
          if (onSync != null) {
            onSync!();
          }
        },
      ),
    );
  }

  Widget _buildRandomizeButton(BuildContext context) {
    return Expanded(
      child: IconButton(
        icon: const Icon(Icons.shuffle),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RandomizeScreen()),
          );
        },
      ),
    );
  }
}
