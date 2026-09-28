import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/utils/responsive_utils.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/habitstats_controller.dart';
import 'stats_neumorphic_utils.dart';

/// Completion rate pie chart widget.
/// Supports both full card view (for charts section) and compact well item (for summary card row).
class CompletionPieChartCard extends StatelessWidget {
  final bool isCompact;

  const CompletionPieChartCard({
    super.key,
    this.isCompact = false,
  });

  const CompletionPieChartCard.compact({
    super.key,
  }) : isCompact = true;

  @override
  Widget build(BuildContext context) {
    final HabitStatsController controller = Get.find<HabitStatsController>();

    return Obx(() {
      final stats = controller.stats.value;
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final textTheme = theme.textTheme;
      final isDark = theme.brightness == Brightness.dark;
      final isPhone = ResponsiveUtils.isPhone(context);

      final Color completedColor = colorScheme.primary; // Emerald
      final Color incompleteColor = colorScheme.error.withValues(alpha: 0.85);

      if (stats == null || stats.totalHabits <= 0) {
        if (isCompact) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: EdgeInsets.symmetric(
                vertical: isPhone ? 1 : 18,
                horizontal: isPhone ? 0 : 12,
              ),
              decoration: StatsNeumorphicTheme.wellDecoration(
                context,
                borderRadius: AppRadius.well,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            centerSpaceRadius: 21,
                            sectionsSpace: 0,
                            sections: [
                              PieChartSectionData(
                                value: 1,
                                showTitle: false,
                                radius: 6,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          );
        }

        return SoftCard(
          child: NeumorphicEmptyState(
            icon: Icons.donut_large_rounded,
            message: S.current.pieChartIsEmpty,
            height: 250,
          ),
        );
      }

      final int completedHabits = stats.completedHabits;
      final int totalHabits = stats.totalHabits;
      final int incompleteHabits = totalHabits - completedHabits;
      final double completionRate = stats.completionRate;

      // ── Compact Mode for Summary Card Row ─────────────────────────────────
      if (isCompact) {
        return Expanded(
          child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(
          vertical: isPhone ? 22 : 16,
          horizontal: isPhone ? 6 : 10,
        ),
            decoration: StatsNeumorphicTheme.wellDecoration(
              context,
              borderRadius: AppRadius.well,
              accentColor: completedColor,
              accentAlpha: isDark ? 0.08 : 0.04,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 25,
                          sectionsSpace: 2,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              value: completedHabits.toDouble(),
                              showTitle: false,
                              radius: 12,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            if (incompleteHabits > 0)
                              PieChartSectionData(
                                value: incompleteHabits.toDouble(),
                                showTitle: false,
                                radius: 6,
                                color: Theme.of(context).colorScheme.error,
         
                                   )
                              
                          ],
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${completionRate.toStringAsFixed(0)}%',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 6),
                // Text(
                //   S.current.success,
                //   style: textTheme.labelSmall?.copyWith(
                //     color: colorScheme.onSurfaceVariant,
                //     fontWeight: FontWeight.w600,
                //     letterSpacing: 0.1,
                //   ),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
              ],
            ),
          ),
        );
      }

      // ── Full Card Mode for Charts Section ──────────────────────────────────
      return SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      centerSpaceRadius: 62,
                      sectionsSpace: 3,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: completedHabits.toDouble(),
                          showTitle: false,
                          radius: 20,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF34D399),
                              Color(0xFF059669),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        if (incompleteHabits > 0)
                          PieChartSectionData(
                            value: incompleteHabits.toDouble(),
                            showTitle: false,
                            radius: 17,
                            color: incompleteColor,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${completionRate.toStringAsFixed(0)}%',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        S.current.success,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Expanded(
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(
            //           vertical: 10,
            //           horizontal: 12,
            //         ),
            //         decoration: StatsNeumorphicTheme.wellDecoration(
            //           context,
            //           borderRadius: AppRadius.md,
            //           accentColor: completedColor,
            //           accentAlpha: isDark ? 0.08 : 0.04,
            //         ),
            //         child: Row(
            //           children: [
            //             Container(
            //               width: 10,
            //               height: 10,
            //               decoration: BoxDecoration(
            //                 color: completedColor,
            //                 shape: BoxShape.circle,
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: completedColor.withValues(alpha: 0.5),
            //                     blurRadius: 4,
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             const SizedBox(width: 8),
            //             Expanded(
            //               child: Text(
            //                 S.current.completed,
            //                 style: textTheme.bodySmall?.copyWith(
            //                   fontWeight: FontWeight.w600,
            //                   color: colorScheme.onSurface,
            //                 ),
            //                 overflow: TextOverflow.ellipsis,
            //               ),
            //             ),
            //             Text(
            //               '$completedHabits',
            //               style: textTheme.bodyMedium?.copyWith(
            //                 fontWeight: FontWeight.bold,
            //                 color: completedColor,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 10),
            //     Expanded(
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(
            //           vertical: 10,
            //           horizontal: 12,
            //         ),
            //         decoration: StatsNeumorphicTheme.wellDecoration(
            //           context,
            //           borderRadius: AppRadius.md,
            //           accentColor: incompleteColor,
            //           accentAlpha: isDark ? 0.08 : 0.04,
            //         ),
            //         child: Row(
            //           children: [
            //             Container(
            //               width: 10,
            //               height: 10,
            //               decoration: BoxDecoration(
            //                 color: incompleteColor,
            //                 shape: BoxShape.circle,
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: incompleteColor.withValues(alpha: 0.5),
            //                     blurRadius: 4,
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             const SizedBox(width: 8),
            //             Expanded(
            //               child: Text(
            //                 S.current.incomplete,
            //                 style: textTheme.bodySmall?.copyWith(
            //                   fontWeight: FontWeight.w600,
            //                   color: colorScheme.onSurface,
            //                 ),
            //                 overflow: TextOverflow.ellipsis,
            //               ),
            //             ),
            //             Text(
            //               '$incompleteHabits',
            //               style: textTheme.bodyMedium?.copyWith(
            //                 fontWeight: FontWeight.bold,
            //                 color: incompleteColor,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
        
          ],
        ),
      );
    });
  }
}

/// Backward-compatible builder function delegating to [CompletionPieChartCard].
Widget buildPieChart() => const CompletionPieChartCard();
