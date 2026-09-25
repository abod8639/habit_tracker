import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_list.dart';
import '../widgets/section_title.dart';
import '../controllers/theme_controller.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) => keyboardShortCutsPages(event),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            color: colorScheme.onSurface,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: Text(
            S.current.themepagetitle,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: S.current.themepage),
              const SizedBox(height: 12),

              // Theme Mode Selector
              // Obx(() => Center(
              //   child: SegmentedButton<ThemeMode>(
              //     segments: const [
              //       ButtonSegment<ThemeMode>(
              //         value: ThemeMode.system,
              //         label: Text('System'),
              //         icon: Icon(Icons.brightness_auto),
              //       ),
              //       ButtonSegment<ThemeMode>(
              //         value: ThemeMode.light,
              //         label: Text('Light'),
              //         icon: Icon(Icons.light_mode),
              //       ),
              //       ButtonSegment<ThemeMode>(
              //         value: ThemeMode.dark,
              //         label: Text('Dark'),
              //         icon: Icon(Icons.dark_mode),
              //       ),
              //     ],
              //     selected: {themeController.themeMode.value},
              //     onSelectionChanged: (Set<ThemeMode> selection) {
              //       themeController.changeThemeMode(selection.first);
              //     },
              //     showSelectedIcon: false,
              //     style: SegmentedButton.styleFrom(
              //       selectedBackgroundColor: colorScheme.primary,
              //       selectedForegroundColor: colorScheme.onPrimary,
              //     ),
              //   ),
              // )),

              // const SizedBox(height: 32),
              // const SectionTitle(title: 'Choose Theme'),
              // const SizedBox(height: 16),

              // Themes Grid
              Obx(() {
                final currentThemeName = themeController.currentTheme.value;
                final availableThemes = themeController.availableThemes;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: availableThemes.length,

                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final themeName = availableThemes[index];
                    final isSelected = currentThemeName == themeName;
                    final colors = themeColors[themeName]!;

                    return ThemeCard(
                      themeName: themeName,
                      colors: colors,
                      isSelected: isSelected,
                      onTap: () => themeController.changeCustomTheme(themeName),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 130),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );

    // Stable dummy data generated once per theme to prevent flicker
    final Map<DateTime, int> data = {};
    final random = Random(widget.themeName.hashCode);
    final today = DateTime.now();
    for (int i = 0; i < 60; i++) {
      if (random.nextDouble() > 0.3) {
        final date = today.subtract(Duration(days: i));
        data[DateTime(date.year, date.month, date.day)] =
            random.nextInt(10) + 1;
      }
    }
    _dummyData = data;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _pressController.forward();
    if (mounted) {
      await _pressController.reverse();
    }
    widget.onTap();
  }

  String _formatThemeName(String name) {
    return name.split('_').map((word) => word.capitalizeFirst ?? word).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final pageTheme = Theme.of(context);
    final pageIsDark = pageTheme.brightness == Brightness.dark;

    final primary = widget.colors['primary']!;
    final surface = widget.colors['surface']!;
    final isCardDark = surface.computeLuminance() < 0.35;

    // Derived HeatMap colorsets from primary
    final Map<int, Color> activeColorSet = {
      1: primary.withValues(alpha: 0.2),
      3: primary.withValues(alpha: 0.4),
      5: primary.withValues(alpha: 0.6),
      7: primary.withValues(alpha: 0.8),
      10: primary,
    };

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isSelected
                  ? [
                      Color.alphaBlend(primary.withValues(alpha: 0.08), surface),
                      Color.alphaBlend(primary.withValues(alpha: 0.02), surface),
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
                ? [
                    // Radiant Neumorphic primary bloom
                    BoxShadow(
                      color: primary.withValues(alpha: pageIsDark ? 0.35 : 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                      spreadRadius: 1,
                    ),
                    // Ambient highlight
                    BoxShadow(
                      color: pageIsDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.9),
                      offset: const Offset(-3, -3),
                      blurRadius: 8,
                    ),
                    // Ambient depth
                    BoxShadow(
                      color: pageIsDark
                          ? Colors.black.withValues(alpha: 0.45)
                          : const Color(0xFFA3B1C6).withValues(alpha: 0.3),
                      offset: const Offset(3, 3),
                      blurRadius: 8,
                    ),
                  ]
                : [
                    // Ambient Neumorphic dual shadows
                    BoxShadow(
                      color: pageIsDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.white.withValues(alpha: 0.9),
                      offset: const Offset(-4, -4),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: pageIsDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : const Color(0xFFA3B1C6).withValues(alpha: 0.32),
                      offset: const Offset(4, 4),
                      blurRadius: 10,
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                // Inset / Sunken HeatMap preview well
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isCardDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCardDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.04),
                      width: 1,
                    ),
                    boxShadow: [
                      // Inner/recessed depth shading
                      BoxShadow(
                        color: isCardDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : const Color(0xFFA3B1C6).withValues(alpha: 0.2),
                        offset: const Offset(1.5, 1.5),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: HeatMap(
                      startDate:
                          DateTime.now().subtract(const Duration(days: 55)),
                      endDate: DateTime.now(),
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
                      colorsets: activeColorSet,
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
                                        ? [
                                            BoxShadow(
                                              color: primary.withValues(
                                                alpha: 0.6,
                                              ),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ]
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
                      if (widget.isSelected)
                        Container(
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
                              BoxShadow(
                                color: primary.withValues(alpha: 0.45),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                              BoxShadow(
                                color: isCardDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.7),
                                offset: const Offset(-2, -2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_rounded,
                              color:
                                  widget.colors['onPrimary'] ?? Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      else
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
                    ],
                  ),
                ),
              ],
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
        boxShadow: [
          BoxShadow(
            color: isCardDark
                ? Colors.black.withValues(alpha: 0.45)
                : const Color(0xFFA3B1C6).withValues(alpha: 0.35),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: isCardDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.8),
            offset: const Offset(-0.8, -0.8),
            blurRadius: 1.5,
          ),
        ],
      ),
    );
  }
}
