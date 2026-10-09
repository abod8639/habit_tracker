import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// Clean Architecture component: Neumorphic debossed input field matching
/// the exact aesthetic of [AiTextInputField] with inverted ambient shadows,
/// soft clay surface, complete curved geometry, and optional helper actions.
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
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool showClearButton;

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
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.showClearButton = true,
  });

  @override
  State<NeumorphicInput> createState() => _NeumorphicInputState();
}

class _NeumorphicInputState extends State<NeumorphicInput> {
  late final TextEditingController _effectiveController;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasText = false;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _effectiveController = TextEditingController();
      _isInternalController = true;
    } else {
      _effectiveController = widget.controller!;
    }

    _hasText = _effectiveController.text.trim().isNotEmpty;
    _effectiveController.addListener(_handleTextChange);

    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void didUpdateWidget(covariant NeumorphicInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_isInternalController) {
        _effectiveController.dispose();
        _isInternalController = false;
      }
      _effectiveController = widget.controller ?? TextEditingController();
      if (widget.controller == null) {
        _isInternalController = true;
      }
      _effectiveController.addListener(_handleTextChange);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTextChange);
    if (_isInternalController) {
      _effectiveController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _effectiveController.text.trim().isNotEmpty;
    if (_hasText != hasText && mounted) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    final effectiveAccent = widget.accentColor ?? colorScheme.primary;
    final effectiveRadius =
        widget.borderRadius ?? const BorderRadius.all(Radius.circular(30));

    // Matching AiTextInputField's exact Neumorphic debossed container
    final Color backgroundColor = isDark
        ? Color.alphaBlend(
            Colors.black.withValues(alpha: 0.32),
            scaffoldBg,
          )
        : const Color(0xFFEFF2F8);

    final Color borderColor = _isFocused
        ? effectiveAccent.withValues(alpha: isDark ? 0.70 : 0.50)
        : (isDark
            ? Colors.black.withValues(alpha: 0.5)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.35));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 1.4 : 1.0,
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
          if (_isFocused)
            ...AppShadows.bloom(
              color: effectiveAccent,
              isDark: isDark,
              blur: 6.0,
              spread: 0.3,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Padding(
          padding: widget.padding ??
              EdgeInsets.symmetric(
                horizontal: widget.isNumber ? 20.0 : 16.0,
                vertical: widget.isNumber ? 12.0 : 4.0,
              ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.prefix != null) ...[
                widget.prefix!,
                const SizedBox(width: 8),
              ] else if (widget.prefixIcon != null) ...[
                Icon(
                  widget.prefixIcon,
                  size: 18,
                  color: effectiveAccent.withValues(alpha: _hasText ? 0.85 : 0.4),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: _effectiveController,
                  onChanged: widget.onChanged,
                  autofocus: widget.autofocus,
                  textAlign: widget.textAlign,
                  keyboardType: widget.isNumber
                      ? TextInputType.number
                      : (widget.maxLines > 1
                          ? TextInputType.multiline
                          : TextInputType.text),
                  inputFormatters: widget.inputFormatters ??
                      (widget.isNumber
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : null),
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  cursorColor: effectiveAccent,
                  style: TextStyle(
                    fontSize: widget.fontSize ?? (widget.isNumber ? 28.0 : 15.0),
                    fontWeight: widget.fontWeight ??
                        (widget.isNumber ? FontWeight.bold : FontWeight.w500),
                    color: widget.isNumber ? effectiveAccent : colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: widget.isNumber
                          ? effectiveAccent.withValues(alpha: 0.30)
                          : colorScheme.onSurface.withValues(alpha: 0.40),
                      fontSize: widget.fontSize ?? (widget.isNumber ? 28.0 : 14.5),
                      fontWeight: widget.fontWeight ??
                          (widget.isNumber ? FontWeight.bold : FontWeight.normal),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: effectiveRadius,
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: effectiveRadius,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: effectiveRadius,
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: effectiveRadius,
                      borderSide: BorderSide.none,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: effectiveRadius,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: widget.isNumber ? 8.0 : 12.0,
                    ),
                  ),
                ),
              ),
              if (widget.unit != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFA3B1C6).withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                    boxShadow: AppShadows.badge(isDark: isDark),
                  ),
                  child: Text(
                    widget.unit!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isFocused ? effectiveAccent : theme.hintColor,
                    ),
                  ),
                ),
              ],
              if (widget.showClearButton && _hasText && !widget.isNumber) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    _effectiveController.clear();
                    widget.onChanged?.call('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ),
              ],
              if (widget.suffix != null) ...[
                const SizedBox(width: 8),
                widget.suffix!,
              ] else if (widget.suffixIcon != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: widget.onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      widget.suffixIcon,
                      size: 20,
                      color: _isFocused ? effectiveAccent : theme.hintColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
