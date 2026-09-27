import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/home/presentation/widget/habit_confirmation_dialog.dart';
import 'package:habit_tracker/features/home/presentation/widget/image_scanner_bottom_sheet.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Neumorphic / Soft UI dialog for adding or editing habits.
/// Features tactile physical depth, dual-source lighting gradients,
/// a debossed well input field, and interactive neumorphic buttons.
class MyalartDialog extends StatefulWidget {
  final Function()? onSave;
  final String? hintText;
  final TextEditingController controller;

  const MyalartDialog({
    this.onSave,
    this.hintText,
    required this.controller,
    super.key,
  });

  @override
  State<MyalartDialog> createState() => _MyalartdState();
}

class _MyalartdState extends State<MyalartDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final FocusNode _keyboardFocusNode = FocusNode();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleScanImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => ImageScannerBottomSheet(
        onImageSelected: (image) async {
          setState(() {
            _isScanning = true;
          });
          try {
            final service = GeminiService();
            final List<String> habits = await service.extractHabitsFromImage(
              image,
            );

            if (mounted) {
              setState(() {
                _isScanning = false;
              });
              Navigator.of(context).pop();
              widget.controller.clear();
              showDialog(
                context: context,
                builder: (context) =>
                    HabitConfirmationDialog(extractedHabits: habits),
              );
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isScanning = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _handleSave() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSave?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  S.current.theFieldCantBeEmpty,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    // Neumorphic surface gradient colors
    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    // Debossed well surface color for input field
    final Color wellBase = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.22) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.30) ?? baseColor);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: AppRadius.dialogRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [surfaceGradientStart, surfaceGradientEnd],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: AppShadows.softCard(isDark: isDark),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon + Title + Action buttons (Scan / Close)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.alphaBlend(
                              colorScheme.primary.withValues(
                                alpha: isDark ? 0.16 : 0.10,
                              ),
                              baseColor,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.90),
                              width: 1.0,
                            ),
                            boxShadow: AppShadows.badge(isDark: isDark),
                          ),
                          child: Icon(
                            Icons.add_task_rounded,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          S.current.add,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isScanning)
                          Container(
                            width: 36,
                            height: 36,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.dotIndicator(isDark: isDark),
                            ),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        else
                          NeumorphicIconButton(
                            size: 36,
                            icon: Icons.document_scanner_rounded,
                            accentColor: colorScheme.primary,
                            tooltip: S.of(context).scanHabitsTitle,
                            onPressed: _handleScanImage,
                          ),
                        const SizedBox(width: 8),
                        NeumorphicIconButton(
                          size: 36,
                          icon: Icons.close_rounded,
                          accentColor: colorScheme.onSurfaceVariant,
                          tooltip: S.current.cancel,
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.controller.clear();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Neumorphic Debossed Well for Text Input
                KeyboardListener(
                  focusNode: _keyboardFocusNode,
                  onKeyEvent: (KeyEvent event) {
                    if (event.physicalKey == PhysicalKeyboardKey.numLock) {
                      return;
                    }
                    if (event is KeyUpEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.escape ||
                          event.logicalKey == LogicalKeyboardKey.exit) {
                        Navigator.of(context).pop();
                        widget.controller.clear();
                      }
                      return;
                    }

                    if (event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.enter ||
                          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                        if (HardwareKeyboard.instance.isControlPressed) {
                          final currentText = widget.controller.text;
                          final currentPosition =
                              widget.controller.selection.base.offset;
                          final validPosition = currentPosition.clamp(
                            0,
                            currentText.length,
                          );
                          final newText =
                              '${currentText.substring(0, validPosition)}\n${currentText.substring(validPosition)}';
                          widget.controller.value = TextEditingValue(
                            text: newText,
                            selection: TextSelection.collapsed(
                              offset: validPosition + 1,
                            ),
                          );
                        } else {
                          _handleSave();
                        }
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: wellBase,
                      borderRadius: AppRadius.lgRadius,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.70),
                        width: 1.0,
                      ),
                      boxShadow: AppShadows.wellDual(isDark: isDark),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: TextFormField(
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.5,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.60,
                          ),
                          fontWeight: FontWeight.w400,
                          fontSize: 14.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.edit_rounded,
                          color: colorScheme.primary.withValues(alpha: 0.75),
                          size: 20,
                        ),
                      ),
                      autofocus: true,
                      controller: widget.controller,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tactile Action Buttons (Cancel & Save)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _NeumorphicDialogButton(
                      label: S.current.cancel,
                      icon: Icons.close_rounded,
                      isPrimary: false,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.controller.clear();
                      },
                    ),
                    const SizedBox(width: 12),
                    _NeumorphicDialogButton(
                      label: S.current.add,
                      icon: Icons.check_rounded,
                      isPrimary: true,
                      onPressed: _handleSave,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tactile Neumorphic Button with press physical depth feedback.
class _NeumorphicDialogButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _NeumorphicDialogButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_NeumorphicDialogButton> createState() => _NeumorphicDialogButtonState();
}

class _NeumorphicDialogButtonState extends State<_NeumorphicDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final Color primaryColor = colorScheme.primary;

    final Color surfaceColor;
    if (widget.isPrimary) {
      surfaceColor = primaryColor;
    } else {
      surfaceColor = isDark
          ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
          : (Color.lerp(baseColor, Colors.white, 0.50) ?? baseColor);
    }

    final Color textColor = widget.isPrimary
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    final Color iconColor = widget.isPrimary
        ? colorScheme.onPrimary
        : colorScheme.error.withValues(alpha: 0.85);

    final List<BoxShadow> shadows;
    if (_isPressed) {
      shadows = AppShadows.buttonPressed(isDark: isDark);
    } else if (widget.isPrimary) {
      shadows = [
        ...AppShadows.bloom(
          color: primaryColor,
          isDark: isDark,
          blur: 10,
          spread: 0.5,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.85),
          offset: const Offset(-2, -2),
          blurRadius: 5,
        ),
      ];
    } else {
      shadows = AppShadows.buttonResting(isDark: isDark);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: AppRadius.mdRadius,
          gradient: widget.isPrimary
              ? LinearGradient(
                  colors: [
                    primaryColor,
                    Color.lerp(
                          primaryColor,
                          Colors.black,
                          isDark ? 0.20 : 0.10,
                        ) ??
                        primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: widget.isPrimary
                ? Colors.white.withValues(alpha: isDark ? 0.15 : 0.40)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.85)),
            width: 1.0,
          ),
          boxShadow: shadows,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 17,
              color: iconColor,
            ),
            const SizedBox(width: 7),
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
