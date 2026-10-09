import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/core/theme/theme_utils.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Neumorphic / Soft UI Habit Matrix heatmap summary widget.
/// Displays a weekly-aligned calendar grid with debossed/recessed tiles
/// for inactive days and glowing gradient pills for completed days tailored to the active theme.
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
  final ScrollController _scrollController = ScrollController();

  static const double _tileSize = 33.0;
  static const double _tileGap = 6.0;
  static const double _headerHeight = 24.0;
  static const double _headerGap = 8.0;

  @override
  void initState() {
    super.initState();
    habitController = Get.find<HabitController>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _getStrength(DateTime normalizedDate, DateTime today) {
    // 1. Live status for today directly from controller so today's progress updates immediately!
    final bool isToday =
        normalizedDate.year == today.year &&
        normalizedDate.month == today.month &&
        normalizedDate.day == today.day;
    if (isToday) {
      final habits = habitController.habits;
      if (habits.isNotEmpty) {
        final completed = habits.where((h) => h.isCompleted).length;
        if (completed > 0) {
          final rate = completed / habits.length;
          final int s = (rate * 10).toInt();
          return s == 0 ? 1 : s;
        } else {
          return 0;
        }
      }
    }

    // 2. Direct lookup in datasets
    if (widget.datasets.containsKey(normalizedDate)) {
      final val = widget.datasets[normalizedDate] ?? 0;
      if (val > 0) return val;
    }

    // 3. Fallback comparison to handle any timezone/UTC difference in keys
    for (final entry in widget.datasets.entries) {
      final k = entry.key;
      final localK = k.isUtc ? k.toLocal() : k;
      if (localK.year == normalizedDate.year &&
          localK.month == normalizedDate.month &&
          localK.day == normalizedDate.day) {
        if (entry.value > 0) return entry.value;
      }
      if (k.year == normalizedDate.year &&
          k.month == normalizedDate.month &&
          k.day == normalizedDate.day) {
        if (entry.value > 0) return entry.value;
      }
    }
    return 0;
  }

  Future<void> _handleDayClick(
    BuildContext context,
    DateTime normalizedDate,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final themeColors = Theme.of(context).colorScheme;
    final status = await habitController.getCompletionStatusForDate(
      normalizedDate,
    );
    final int completed = status['completed'] ?? 0;
    final int total = status['total'] ?? 0;

    if (!mounted) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: themeColors.primary.withValues(alpha: 0.95),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
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
                color: themeColors.onPrimary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // In Sunday-first calendar: Sunday is day 0, Monday 1, ..., Saturday 6
    final int daysSinceSunday = today.weekday % 7;
    // Safe calendar subtraction avoiding DST drift
    final DateTime currentWeekSunday = DateTime(
      today.year,
      today.month,
      today.day - daysSinceSunday,
    );

    // End on the upcoming week so today and the current week are never jammed against the border
    final DateTime endSunday = DateTime(
      currentWeekSunday.year,
      currentWeekSunday.month,
      currentWeekSunday.day + 7,
    );

    DateTime startDateTime;
    try {
      startDateTime = createDateTimeObject(habitController.getStartDay());
    } catch (_) {
      startDateTime = DateTime(today.year, today.month, today.day - 49);
    }

    DateTime startSunday = DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day - (startDateTime.weekday % 7),
    );

    // Ensure at least 8 full weeks are visible (7 past weeks + upcoming week)
    final DateTime minStartSunday = DateTime(
      endSunday.year,
      endSunday.month,
      endSunday.day - (7 * 7),
    );
    if (startSunday.isAfter(minStartSunday)) {
      startSunday = minStartSunday;
    }

    // Build the list of Sunday dates for every week column
    final List<DateTime> weekSundays = [];
    DateTime cursor = startSunday;
    while (!cursor.isAfter(endSunday)) {
      weekSundays.add(cursor);
      cursor = DateTime(cursor.year, cursor.month, cursor.day + 7);
    }

    // 7 Weekday labels (Sun, Mon, Tue, Wed, Thu, Fri, Sat)
    final List<String> weekdayLabels = List.generate(7, (index) {
      final dayDate = DateTime(
        currentWeekSunday.year,
        currentWeekSunday.month,
        currentWeekSunday.day + index,
      );
      return DateFormat.E(locale).format(dayDate);
    });

    // Month headers for each column (e.g. Mar, Apr, May)
    final List<String> monthLabels = [];
    for (int i = 0; i < weekSundays.length; i++) {
      final weekSunday = weekSundays[i];
      bool showMonth = false;
      if (i == 0) {
        showMonth = true;
      } else {
        final prevSunday = weekSundays[i - 1];
        if (weekSunday.month != prevSunday.month) {
          showMonth = true;
        }
      }
      monthLabels.add(
        showMonth ? DateFormat.MMM(locale).format(weekSunday) : '',
      );
    }

    final Color labelColor = theme.colorScheme.onSurface.withValues(
      alpha: isDark ? 0.60 : 0.65,
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_animationController),
        child: SoftCard(
          borderRadius: 28.0,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          // Force LTR directionality so calendar consistently flows from past (left) to present (right)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pinned Weekday Labels Column (Sun, Mon, Tue, Wed, Thu, Fri, Sat)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _headerHeight + _headerGap),
                  ...List.generate(7, (index) {
                    return Container(
                      height: _tileSize,
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(
                        bottom: index < 6 ? _tileGap : 0,
                      ),
                      child: Text(
                        weekdayLabels[index],
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: labelColor,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(width: 8),
              // Horizontally Scrollable Matrix Grid anchored to the present/future weeks
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  reverse:
                      true, // Natively anchors scroll to the latest weeks/today!
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Headers Row (Mar, Apr, May...)
                      Row(
                        children: List.generate(weekSundays.length, (colIdx) {
                          return Container(
                            width: _tileSize,
                            height: _headerHeight,
                            margin: EdgeInsets.only(
                              right: colIdx < weekSundays.length - 1
                                  ? _tileGap
                                  : 0,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              monthLabels[colIdx],
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: labelColor,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: _headerGap),
                      // Day Tile Matrix
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(weekSundays.length, (colIdx) {
                          final weekSunday = weekSundays[colIdx];
                          return Container(
                            margin: EdgeInsets.only(
                              right: colIdx < weekSundays.length - 1
                                  ? _tileGap
                                  : 0,
                            ),
                            child: Column(
                              children: List.generate(7, (rowIdx) {
                                final dayDate = DateTime(
                                  weekSunday.year,
                                  weekSunday.month,
                                  weekSunday.day + rowIdx,
                                );
                                final normalizedDay = DateTime(
                                  dayDate.year,
                                  dayDate.month,
                                  dayDate.day,
                                );
                                final isToday =
                                    normalizedDay.year == today.year &&
                                    normalizedDay.month == today.month &&
                                    normalizedDay.day == today.day;
                                final isFuture = normalizedDay.isAfter(today);
                                final strength = _getStrength(
                                  normalizedDay,
                                  today,
                                );

                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: rowIdx < 6 ? _tileGap : 0,
                                  ),
                                  child: _NeumorphicDayTile(
                                    date: dayDate,
                                    strength: strength,
                                    isToday: isToday,
                                    isFuture: isFuture,
                                    size: _tileSize,
                                    onTap: () => _handleDayClick(
                                      context,
                                      normalizedDay,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ],
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

/// An individual day tile designed with Neumorphic / Soft UI aesthetics.
/// - Uncompleted (strength == 0): debossed recessed surface with dual soft shadows.
/// - Progressing (strength 1..10): progressive emerald gradient and ambient glow proportional to completion strength.
/// - Today: highlighted accent border.
/// - Future: dimmed opacity.
class _NeumorphicDayTile extends StatefulWidget {
  final DateTime date;
  final int strength; // 0 to 10
  final bool isToday;
  final bool isFuture;
  final double size;
  final VoidCallback? onTap;

  const _NeumorphicDayTile({
    required this.date,
    required this.strength,
    required this.isToday,
    required this.isFuture,
    required this.size,
    this.onTap,
  });

  @override
  State<_NeumorphicDayTile> createState() => _NeumorphicDayTileState();
}

class _NeumorphicDayTileState extends State<_NeumorphicDayTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final secondary = colorScheme.secondary;

    // Harmonious gradient endpoints derived dynamically from the active theme's palette
    final Color activeStart = isDark
        ? (Color.lerp(primary, Colors.white, 0.14) ?? primary)
        : (Color.lerp(primary, Colors.white, 0.08) ?? primary);
    final Color activeEnd = Color.lerp(secondary, primary, 0.35) ?? primary;

    // Recessed base for inactive tiles derived natively from cardColor to maintain theme hue
    final Color inactiveBase = isDark
        ? (Color.lerp(theme.cardColor, Colors.black, 0.25) ?? theme.cardColor)
        : (Color.lerp(theme.cardColor, Colors.black, 0.06) ?? theme.cardColor);

    BoxDecoration decoration;
    TextStyle textStyle;

    final bool isCompleted = widget.strength > 0;

    if (isCompleted) {
      // Progress ratio from 0.1 to 1.0 based on completion strength (1 to 10)
      final double progress = (widget.strength / 10.0).clamp(0.1, 1.0);
      final double t = ((progress - 0.1) / 0.9).clamp(0.0, 1.0);

      // Low strength gives a gentle theme tint; high strength gives vibrant theme gradient
      final Color minStart = Color.lerp(
        inactiveBase,
        activeStart,
        isDark ? 0.32 : 0.25,
      )!;
      final Color minEnd = Color.lerp(
        inactiveBase,
        activeEnd,
        isDark ? 0.38 : 0.30,
      )!;

      final Color startColor = Color.lerp(minStart, activeStart, t)!;
      final Color endColor = Color.lerp(minEnd, activeEnd, t)!;

      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        border: Border.all(
          color: widget.isToday
              ? Colors.white.withValues(alpha: isDark ? 0.55 : 0.95)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.10 + (progress * 0.16))
                    : Colors.white.withValues(alpha: 0.35 + (progress * 0.35))),
          width: widget.isToday ? 1.5 : 1.0,
        ),
        boxShadow: AppShadows.heatMapTile(
          primary: primary,
          isDark: isDark,
          progress: progress,
        ),
      );

      final Color textColor = isDark
          ? Colors.white.withValues(alpha: 0.90 + (progress * 0.10))
          : ThemeUtils.getContrastColor(startColor).withValues(
              alpha: progress >= 0.5 ? 0.95 : 0.85,
            );

      textStyle = TextStyle(
        color: textColor,
        fontSize: 12.5,
        fontWeight: progress >= 0.5 ? FontWeight.bold : FontWeight.w600,
      );
    } else {
      decoration = BoxDecoration(
        color: inactiveBase,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: widget.isToday
              ? primary.withValues(alpha: 0.85)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.65)),
          width: widget.isToday ? 1.5 : 0.8,
        ),
        boxShadow: widget.isToday
            ? AppShadows.heatMapTodayHighlight(
                primary: primary,
                isDark: isDark,
              )
            : AppShadows.dotIndicator(isDark: isDark),
      );
      textStyle = TextStyle(
        color: widget.isToday
            ? (isDark ? Colors.white : primary)
            : colorScheme.onSurface.withValues(alpha: isDark ? 0.50 : 0.55),
        fontSize: 12.5,
        fontWeight: widget.isToday ? FontWeight.bold : FontWeight.w500,
      );
    }

    Widget tile = AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: widget.size,
        height: widget.size,
        decoration: decoration,
        child: Center(
          child: Text(
            widget.date.day.toString(),
            style: textStyle,
          ),
        ),
      ),
    );

    if (widget.isFuture) {
      tile = Opacity(
        opacity: 0.32,
        child: tile,
      );
    }

    return GestureDetector(
      onTapDown: widget.onTap != null && !widget.isFuture
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null && !widget.isFuture
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isFuture ? null : widget.onTap,
      child: tile,
    );
  }
}
