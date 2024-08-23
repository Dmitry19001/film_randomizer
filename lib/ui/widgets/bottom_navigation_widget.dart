import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final VoidCallback? onSync;
  final VoidCallback? onOpenRandomizer;

  const CustomBottomNavigation({super.key, this.onSync, this.onOpenRandomizer});

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
          if (onSync == null) return;
          onSync!();
        },
      ),
    );
  }

  Widget _buildRandomizeButton(BuildContext context) {
    return Expanded(
      child: IconButton(
        icon: const Icon(Icons.shuffle),
        onPressed: () {
          if (onOpenRandomizer == null) return;
          onOpenRandomizer!();
        },
      ),
    );
  }
}
