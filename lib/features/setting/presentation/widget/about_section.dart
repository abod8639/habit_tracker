import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/generated/l10n.dart';

class AboutSection extends StatelessWidget {
  final AnimationController animationController;

  const AboutSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      children: [
        AnimatedSettingTile(
          animationController: animationController,
          index: 12,
          icon: Icons.info_outline_rounded,
          title: s.about,
          subtitle: s.appVersionAndInformation,
          onTap: () {
            context.push(AppRoutes.about);
          },
        ),
      ],
    );
  }
}

Widget buildAboutSection(AnimationController animationController) {
  return AboutSection(animationController: animationController);
}
