import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/functions/navigate_tologin.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

class AccountSection extends StatelessWidget {
  final AnimationController animationController;

  const AccountSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return Obx(() {
      final user = authController.currentUser;
      if (user != null) {
        return Column(
          children: [
            buildAnimatedUserCard(
              animationController,
              user.displayName ?? S.current.user,
              user.email ?? '',
              user.photoUrl,
              1,
            ),
          ],
        );
      } else {
        return Column(
          children: [
            AnimatedSettingTile(
              animationController: animationController,
              index: 1,
              icon: Icons.login_rounded,
              title: S.current.loginToAccount,
              subtitle: S.current.loginToEnableSync,
              onTap: () => navigateToLogin(),
            ),
          ],
        );
      }
    });
  }
}

Widget buildAccountSection(AnimationController animationController) {
  return AccountSection(animationController: animationController);
}

Widget buildAnimatedUserCard(
  AnimationController animationController,
  String name,
  String email,
  String? photoUrl,
  int index,
) {
  final Animation<double> animation = CurvedAnimation(
    parent: animationController,
    curve: Interval(
      0.05 * (index % 10),
      math.min(0.05 * (index % 10) + 0.5, 1.0),
      curve: Curves.easeOut,
    ),
  );

  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(animation),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.tertiaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.cardRadius,
              boxShadow: AppShadows.softCard(isDark: isDark),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.5),
                      width: 3,
                    ),
                    boxShadow: AppShadows.dotIndicator(isDark: isDark),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    onBackgroundImageError: photoUrl != null
                        ? (exception, stackTrace) {
                            // debugPrint('Error loading profile image: $exception');
                          }
                        : null,
                    child: photoUrl == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 36,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.1,
                              ),
                          borderRadius: AppRadius.mdRadius,
                        ),
                        child: Text(
                          email,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
