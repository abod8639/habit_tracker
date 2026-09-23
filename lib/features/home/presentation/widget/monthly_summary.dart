import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:habit_tracker/generated/l10n.dart';

class MonthlySummary extends StatefulWidget {
  final Map<DateTime, int> datasets;

  const MonthlySummary({super.key, required this.datasets});

  @override
  State<MonthlySummary> createState() => _MonthlySummaryState();
}

class _MonthlySummaryState extends State<MonthlySummary>
    with SingleTickerProviderStateMixin {
  late HabitController habitController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  double _heatMapSize = 37;

  @override
  void initState() {
    super.initState();
    habitController = Get.find<HabitController>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDateTime;
    try {
      startDateTime = createDateTimeObject(habitController.getStartDay());
    } catch (e) {
      startDateTime = DateTime.now().subtract(const Duration(days: 30));
    }

    final themeColors = Theme.of(context).colorScheme;
    final primaryColor = themeColors.primary;

    final colorsets = {
      1: primaryColor.withValues(alpha: 0.1),
      2: primaryColor.withValues(alpha: 0.2),
      3: primaryColor.withValues(alpha: 0.3),
      4: primaryColor.withValues(alpha: 0.4),
      5: primaryColor.withValues(alpha: 0.5),
      6: primaryColor.withValues(alpha: 0.6),
      7: primaryColor.withValues(alpha: 0.7),
      8: primaryColor.withValues(alpha: 0.8),
      9: primaryColor.withValues(alpha: 0.9),
      10: primaryColor.withValues(alpha: 1.0),
    };

    final double topPadding = MediaQuery.of(context).size.width * 0.05;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _heatMapSize = 27;
        });
      },
      onLongPressUp: () {
        setState(() {
          _heatMapSize = 37;
        });
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_animationController),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: 2, top: topPadding, bottom: 25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: HeatMap(
                    key: ValueKey(
                      'bg_heatmap_${startDateTime.year}_${startDateTime.month}_${startDateTime.day}',
                    ),
                    startDate: startDateTime,
                    fontSize: 16,
                    endDate: DateTime.now().add(const Duration(days: 15)),
                    colorMode: ColorMode.color,
                    defaultColor: Colors.grey[400]!.withAlpha(20),
                    textColor: themeColors.onSurface,
                    showColorTip: false,
                    showText: true,
                    scrollable: true,
                    size: _heatMapSize,
                    colorsets: colorsets,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 2.6,
                  top: topPadding,
                  bottom: 25,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: HeatMap(
                    // colorTipHelper: [
                    // Container(
                    //   color: Colors.grey[400],
                    //   width: 10,
                    //   height: 10,
                    //   )
                    // ],
                    key: ValueKey(
                      'data_heatmap_${startDateTime.year}_${startDateTime.month}_${startDateTime.day}_${widget.datasets.isEmpty}',
                    ),
                    startDate: startDateTime,
                    fontSize: 16,
                    endDate: DateTime.now(),
                    datasets: widget.datasets,
                    colorMode: ColorMode.color,
                    defaultColor: Colors.grey[400]!,
                    textColor: themeColors.onSurface,
                    showColorTip: false,
                    showText: true,
                    scrollable: true,
                    size: _heatMapSize,
                    colorsets: colorsets,
                    onClick: (value) async {
                      final messenger = ScaffoldMessenger.of(context);
                      final localDate = value.isUtc ? value.toLocal() : value;
                      final normalizedDate = DateTime(
                        localDate.year,
                        localDate.month,
                        localDate.day,
                      );
                      final status = await habitController
                          .getCompletionStatusForDate(normalizedDate);
                      final int completed = status['completed'] ?? 0;
                      final int total = status['total'] ?? 0;

                      if (mounted) {
                        messenger.clearSnackBars();
                        messenger.showSnackBar(
                          SnackBar(
                            backgroundColor: themeColors.primary.withValues(
                              alpha: 0.9,
                            ),
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            behavior: SnackBarBehavior.floating,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      S.current.completed,
                                      style: TextStyle(
                                        color: themeColors.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "$completed / $total",
                                      style: TextStyle(
                                        color: themeColors.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: themeColors.onPrimary.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
