import 'package:film_randomizer/ui/screens/randomizer_page.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final VoidCallback? onSync;

  const CustomBottomNavigation({super.key, this.onSync});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              onSync?.call();
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              // Navigate to the RandomizeScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RandomizeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
