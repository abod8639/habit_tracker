import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/home/presentation/widget/image_scanner_bottom_sheet.dart';
import 'package:habit_tracker/features/home/presentation/widget/habit_confirmation_dialog.dart';

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
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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
            final List<String> habits = 
            await service.extractHabitsFromImage(image);

            if (mounted) {
              setState(() {
                _isScanning = false;
              });
              // Close the Add Habit dialog
              Navigator.of(context).pop();
              widget.controller.clear();
              // Show the confirmation dialog
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
              // debugPrint(e.toString());
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
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
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AlertDialog(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: colorScheme.primary.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with icon
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_task_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      S.current.add,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (_isScanning)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.document_scanner_rounded),
                      color: colorScheme.primary,
                      tooltip: S.of(context).scanHabitsTitle,
                      onPressed: _handleScanImage,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Input field
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
                        final validPosition =
                            currentPosition.clamp(0, currentText.length);
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
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.edit_rounded,
                        color: colorScheme.primary.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                    autofocus: true,
                    controller: widget.controller,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Keyboard shortcuts hint
              // Text(
              //   'Press Enter to save • Ctrl+Enter for new line • Esc to cancel',
              //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //         color: colorScheme.onSurfaceVariant.withValues(alpha:0.6),
              //         fontSize: 11,
              //       ),
              // ),
            ],
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.controller.clear();
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    S.current.cancel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Save button
            FilledButton(
              onPressed: _handleSave,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    S.current.add,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
}
