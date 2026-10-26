import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
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
  final String? title;
  final String? actionButtonText;
  final bool isEditing;
  final TextEditingController controller;

  const MyalartDialog({
    this.onSave,
    this.hintText,
    this.title,
    this.actionButtonText,
    this.isEditing = false,
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
      isScrollControlled: true,
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
              final failure = NetworkErrorHandler.handle(e);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.toMessage()),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
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

    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final String dialogTitle =
        widget.title ??
        (widget.isEditing
            ? S.current.editThisHabit
            : (isAr ? 'إضافة عادة' : 'Add Habit'));
    final String buttonLabel =
        widget.actionButtonText ??
        (widget.isEditing
            ? (isAr ? 'تعديل' : 'Edit')
            : (isAr ? 'إضافة' : 'Add'));

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 32,
          ),
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
            child: SingleChildScrollView(
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
                              widget.isEditing
                                  ? Icons.edit_rounded
                                  : Icons.add_task_rounded,
                              color: colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            dialogTitle,
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
                                boxShadow: AppShadows.dotIndicator(
                                  isDark: isDark,
                                ),
                              ),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            )
                          else if (!widget.isEditing)
                            NeumorphicIconButton(
                              size: 40,
                              icon: Icons.document_scanner_rounded,
                              accentColor: colorScheme.primary,
                              tooltip: S.of(context).scanHabitsTitle,
                              onPressed: _handleScanImage,
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
                            event.logicalKey ==
                                LogicalKeyboardKey.numpadEnter) {
                          if (HardwareKeyboard.instance.isControlPressed) {
                            final currentText = widget.controller.text;
                            final selection = widget.controller.selection;
                            final start = selection.start.clamp(
                              0,
                              currentText.length,
                            );
                            final end = selection.end.clamp(
                              0,
                              currentText.length,
                            );
                            final newText = currentText.replaceRange(
                              start,
                              end,
                              '\n',
                            );
                            widget.controller.value = TextEditingValue(
                              text: newText,
                              selection: TextSelection.collapsed(
                                offset: start + 1,
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
                      child: TextFormField(
                        maxLength: 100,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.5,
                          color: colorScheme.onSurface,
                        ),
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintMaxLines: 100,
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        label: buttonLabel,
                        icon: widget.isEditing
                            ? Icons.edit_rounded
                            : Icons.check_rounded,
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
  State<_NeumorphicDialogButton> createState() =>
      _NeumorphicDialogButtonState();
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
              size: 20,
              color: iconColor,
              shadows: AppShadows.buttonPressed(isDark: isDark),
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
