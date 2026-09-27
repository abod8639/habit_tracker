import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';

/// Tactile Neumorphic Drawer menu button for tablet/large screens.
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: NeumorphicIconButton.square(
            size: 46,
            icon: Icons.menu_rounded,
            iconSize: 22,
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        );
      },
    );
  }
}
