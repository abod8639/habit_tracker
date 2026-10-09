import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// A tactile Neumorphic input container with debossed inner well shadows,
/// subtle lighting borders, and reactive focus highlighting.
class NeumorphicInput extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final String? unit;
  final Color? accentColor;
  final bool autofocus;
  final bool isNumber;
  final TextAlign textAlign;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int minLines;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const NeumorphicInput({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText,
    this.unit,
    this.accentColor,
    this.autofocus = false,
    this.isNumber = false,
    this.textAlign = TextAlign.start,
    this.fontSize,
    this.fontWeight,
    this.minLines = 1,
    this.maxLines = 1,
    this.inputFormatters,
    this.padding,
    this.borderRadius,
  });

  @override
  State<NeumorphicInput> createState() => _NeumorphicInputState();
}

class _NeumorphicInputState extends State<NeumorphicInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final effectiveAccent = widget.accentColor ?? colorScheme.primary;
    final effectiveRadius = widget.borderRadius ?? AppRadius.mdRadius;

    final Color wellColor = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.28) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.35) ?? baseColor);

    final Color borderColor = _isFocused
        ? effectiveAccent.withValues(alpha: isDark ? 0.65 : 0.50)
        : (isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.80));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: wellColor,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: AppShadows.insetInput(isDark: isDark),
      ),
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              onChanged: widget.onChanged,
              autofocus: widget.autofocus,
              textAlign: widget.textAlign,
              keyboardType: widget.isNumber ? TextInputType.number : TextInputType.text,
              inputFormatters: widget.inputFormatters ??
                  (widget.isNumber ? [FilteringTextInputFormatter.digitsOnly] : null),
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              style: TextStyle(
                fontSize: widget.fontSize ?? 16.0,
                fontWeight: widget.fontWeight ?? (widget.isNumber ? FontWeight.bold : FontWeight.normal),
                color: widget.isNumber ? effectiveAccent : colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: widget.isNumber
                      ? effectiveAccent.withValues(alpha: 0.35)
                      : theme.hintColor.withValues(alpha: 0.5),
                  fontSize: widget.fontSize,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
          if (widget.unit != null) ...[
            const SizedBox(width: 8),
            Text(
              widget.unit!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
