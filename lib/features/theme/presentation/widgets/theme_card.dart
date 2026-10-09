import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/generated/l10n.dart';

class ThemeCard extends StatefulWidget {
  final String themeName;
  final Map<String, Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.themeName,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<ThemeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  late final Map<DateTime, int> _dummyData;
  late final DateTime _startDate;
  late final DateTime _endDate;
  late final Map<int, Color> _activeColorSet;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );

    final today = DateTime.now();
    _endDate = today;
    _startDate = today.subtract(const Duration(days: 55));

    final primary = widget.colors['primary']!;
    _activeColorSet = {
      1: primary.withValues(alpha: 0.2),
      3: primary.withValues(alpha: 0.4),
      5: primary.withValues(alpha: 0.6),
      7: primary.withValues(alpha: 0.8),
      10: primary,
    };

    // Stable dummy data generated once per theme to prevent flicker and redundant computation
    _dummyData = _dummyDataCache.putIfAbsent(widget.themeName, () {
      final Map<DateTime, int> data = {};
      final random = Random(widget.themeName.hashCode);
      for (int i = 0; i < 60; i++) {
        if (random.nextDouble() > 0.3) {
          final date = today.subtract(Duration(days: i));
          data[DateTime(date.year, date.month, date.day)] =
              random.nextInt(10) + 1;
        }
      }
      return data;
    });
  }

  static final Map<String, Map<DateTime, int>> _dummyDataCache = {};

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isSelected) return;
    _pressController.forward().then((_) {
      if (mounted) {
        _pressController.reverse();
      }
    });
    widget.onTap();
  }

  String _formatThemeName(String name) {
    return name
        .split('_')
        .map((word) => word.capitalizeFirst ?? word)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final pageTheme = Theme.of(context);
    final pageIsDark = pageTheme.brightness == Brightness.dark;

    final primary = widget.colors['primary']!;
    final surface = widget.colors['surface']!;
    final isCardDark = surface.computeLuminance() < 0.35;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isSelected
                    ? [
                        Color.alphaBlend(
                          primary.withValues(alpha: 0.08),
                          surface,
                        ),
                        Color.alphaBlend(
                          primary.withValues(alpha: 0.02),
                          surface,
                        ),
                      ]
                    : [
                        isCardDark
                            ? Color.alphaBlend(
                                Colors.white.withValues(alpha: 0.04),
                                surface,
                              )
                            : Color.alphaBlend(
                                Colors.white.withValues(alpha: 0.45),
                                surface,
                              ),
                        surface,
                      ],
              ),
              border: Border.all(
                color: widget.isSelected
                    ? primary
                    : (pageIsDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06)),
                width: widget.isSelected ? 2.2 : 1.0,
              ),
              boxShadow: widget.isSelected
                  ? AppShadows.selectedCard(
                      primary: primary,
                      isDark: pageIsDark,
                    )
                  : AppShadows.subtleCard(isDark: pageIsDark),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.cardRadius,
              child: Column(
                children: [
                  // Inset / Sunken HeatMap preview well
                  RepaintBoundary(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isCardDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : const Color(0xFFF3F5F9),
                        borderRadius: AppRadius.wellRadius,
                        border: Border.all(
                          color: isCardDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.04),
                          width: 1,
                        ),
                        boxShadow: AppShadows.insetWell(isDark: isCardDark),
                      ),
                      child: Center(
                        child: HeatMap(
                          startDate: _startDate,
                          endDate: _endDate,
                          datasets: _dummyData,
                          colorMode: ColorMode.color,
                          defaultColor: isCardDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.05),
                          textColor: isCardDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.45),
                          showColorTip: false,
                          showText: false,
                          scrollable: false,
                          size: 16,
                          colorsets: _activeColorSet,
                        ),
                      ),
                    ),
                  ),

                  // Bottom bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? primary.withValues(alpha: isCardDark ? 0.12 : 0.07)
                          : (isCardDark
                                ? Colors.black.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.02)),
                      border: Border(
                        top: BorderSide(
                          color: widget.isSelected
                              ? primary.withValues(alpha: 0.25)
                              : (isCardDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05)),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatThemeName(widget.themeName),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget.isSelected
                                          ? primary
                                          : (isCardDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.35,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.35,
                                                  )),
                                      boxShadow: widget.isSelected
                                          ? AppShadows.activeDot(color: primary)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.isSelected
                                        ? S.of(context).currentlySelected
                                        : S.of(context).tapToApply,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: widget.isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: widget.isSelected
                                          ? primary
                                          : (isCardDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.65,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.55,
                                                  )),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            if (widget.colors['primary'] != null)
                              _buildColorIndicator(
                                widget.colors['primary']!,
                                isCardDark,
                              ),
                            if (widget.colors['secondary'] != null)
                              _buildColorIndicator(
                                widget.colors['secondary']!,
                                isCardDark,
                              ),
                            if (widget.colors['surface'] != null)
                              _buildColorIndicator(
                                widget.colors['surface']!,
                                isCardDark,
                              ),
                            if (widget.colors['background'] != null)
                              _buildColorIndicator(
                                widget.colors['background']!,
                                isCardDark,
                              ),
                            if (widget.colors['onPrimary'] != null)
                              _buildColorIndicator(
                                widget.colors['onPrimary']!,
                                isCardDark,
                              ),
                            if (widget.colors['onSecondary'] != null)
                              _buildColorIndicator(
                                widget.colors['onSecondary']!,
                                isCardDark,
                              ),
                            if (widget.colors['error'] != null)
                              _buildColorIndicator(
                                widget.colors['error']!,
                                isCardDark,
                              ),
                          ],
                        ),
                        widget.isSelected
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.alphaBlend(
                                          Colors.white.withValues(alpha: 0.25),
                                          primary,
                                        ),
                                        primary,
                                      ],
                                    ),
                                    boxShadow: [
                                      ...AppShadows.bloom(
                                        color: primary,
                                        isDark: isCardDark,
                                        blur: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                      BoxShadow(
                                        color: isCardDark
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.7,
                                              ),
                                        offset: const Offset(-2, -2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check_rounded,
                                      color:
                                          widget.colors['onPrimary'] ??
                                          Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorIndicator(Color color, bool isCardDark) {
    return Container(
      width: 15,
      height: 15,
      margin: const EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCardDark
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.12),
          width: 0.75,
        ),
        boxShadow: AppShadows.dotIndicator(isDark: isCardDark),
      ),
    );
  }
}
