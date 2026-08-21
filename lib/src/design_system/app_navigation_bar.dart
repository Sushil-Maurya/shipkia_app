import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/shipkia_colors.dart';
import 'app_platform.dart';

class AppNavigationDestination {
  const AppNavigationDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<AppNavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    if (AppPlatform.isCupertino) {
      return CupertinoTabBar(
        currentIndex: selectedIndex,
        onTap: onSelected,
        activeColor: ShipKiaColors.shipkiaBlue,
        items: [
          for (final destination in destinations)
            BottomNavigationBarItem(
              icon: Icon(destination.icon),
              label: destination.label,
            ),
        ],
      );
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        for (final destination in destinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            label: destination.label,
          ),
      ],
    );
  }
}
