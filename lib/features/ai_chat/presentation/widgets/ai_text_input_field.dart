import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Clean Architecture component: Neumorphic debossed text field with
/// inverted ambient shadows, complete oval geometry, and embedded helper actions.
class AiTextInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final VoidCallback? onSubmitted;

  const AiTextInputField({
    super.key,
    required this.controller,
    this.hintText,
    this.onSubmitted,
  });

  @override
  State<AiTextInputField> createState() => _AiTextInputFieldState();
}

class _AiTextInputFieldState extends State<AiTextInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final primary = theme.colorScheme.primary;

    const borderRadius = BorderRadius.all(Radius.circular(30));

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Color.alphaBlend(
                Colors.black.withValues(alpha: 0.32),
                scaffoldBg,
              )
            : const Color(0xFFEFF2F8),
        borderRadius: borderRadius,
        border: Border.all(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : const Color(0xFFA3B1C6).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          // Top-left sunken depth shadow
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : const Color(0xFFA3B1C6).withValues(alpha: 0.4),
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          // Bottom-right inner highlight
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.035)
                : Colors.white.withValues(alpha: 0.95),
            offset: const Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: TextField(
          autofocus: false,
          controller: widget.controller,
          maxLines: 5,
          minLines: 1,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.transparent,
            hintText: widget.hintText ?? S.current.typeMessage,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 14.5,
            ),
            border: const OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide.none,
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide.none,
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide.none,
            ),
            disabledBorder: const OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: primary.withValues(alpha: _hasText ? 0.85 : 0.38),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 38,
              minHeight: 24,
            ),
            suffixIcon: _hasText
                ? GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                    },
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 14),
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 38,
              minHeight: 24,
            ),
          ),
        ),
      ),
    );
  }
}
