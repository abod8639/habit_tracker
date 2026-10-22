import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/ai_chat/domain/entities/chat_message_entity.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'ai_avatar.dart';

/// Neumorphic styled message bubble supporting user and AI responses with
/// molded 3D dual shadows, soft convex gradients, and tactile feedback.
class AiMessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isLast;
  final VoidCallback onRetry;

  const AiMessageBubble({
    super.key,
    required this.message,
    required this.isLast,
    required this.onRetry,
  });

  void _copyToClipboard(BuildContext context, String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(isArabic ? 'تم نسخ الرسالة' : 'Message copied to clipboard'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.inverseSurface.withValues(alpha: 0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUser = message.isUser;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Retry button for user failed message
          if (isUser && message.hasError) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _NeumorphicRetryButton(
                onPressed: onRetry,
                tooltip: S.of(context).retry,
              ),
            ),
          ],

          // AI avatar on the start side
          if (!isUser) ...[
            const AiAvatar(size: 32),
            const SizedBox(width: 10),
          ],

          // Neumorphic message bubble container
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(context, message.text),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.76,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? LinearGradient(
                          colors: [
                            Color.alphaBlend(
                              Colors.white.withValues(alpha: 0.02),
                              primary,
                            ),
                            primary,
                            Color.alphaBlend(
                              Colors.black.withValues(alpha: 0.02),
                              secondary,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: isDark
                              ? [
                                  Color.alphaBlend(
                                    Colors.white.withValues(alpha: 0.06),
                                    scaffoldBg,
                                  ),
                                  Color.alphaBlend(
                                    Colors.black.withValues(alpha: 0.18),
                                    scaffoldBg,
                                  ),
                                ]
                              : [
                                  Colors.white,
                                  Color.alphaBlend(
                                    const Color(0xFFA3B1C6).withValues(
                                      alpha: 0.12,
                                    ),
                                    scaffoldBg,
                                  ),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(22),
                    topRight: const Radius.circular(22),
                    bottomLeft: isUser
                        ? const Radius.circular(22)
                        : const Radius.circular(5),
                    bottomRight: isUser
                        ? const Radius.circular(5)
                        : const Radius.circular(22),
                  ),
                  border: Border.all(
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.28)
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.85)),
                    width: 1.0,
                  ),
                  boxShadow: AppShadows.softCard(isDark: isDark)
                ),
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (!isUser) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 11.5,
                            color: primary.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            S.current.aiCoach,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primary.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.5,

                        letterSpacing: -0.1,
                        color: isUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeumorphicRetryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const _NeumorphicRetryButton({
    required this.onPressed,
    required this.tooltip,
  });

  @override
  State<_NeumorphicRetryButton> createState() => _NeumorphicRetryButtonState();
}

class _NeumorphicRetryButtonState extends State<_NeumorphicRetryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    if (mounted) {
      await _controller.reverse();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: widget.tooltip,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: AppShadows.badge(isDark: isDark),
            ),
            child: Icon(
              Icons.refresh_rounded,
              size: 18,
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
