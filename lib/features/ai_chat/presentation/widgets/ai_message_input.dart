import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ai_send_button.dart';
import 'ai_text_input_field.dart';

/// Clean Architecture Component: Neumorphic message input bar orchestrator.
/// Combines the debossed [AiTextInputField] and convex 3D [AiSendButton] into
/// a unified, high-performance input dock.
class AiMessageInput extends StatelessWidget {
  final TextEditingController textController;
  final RxBool isLoading;
  final VoidCallback onSend;

  const AiMessageInput({
    super.key,
    required this.textController,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: scaffoldBg,
        boxShadow: [
          // Ambient top lighting separating the input bar from the message feed
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : const Color(0xFFA3B1C6).withValues(alpha: 0.25),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.white.withValues(alpha: 0.8),
            offset: const Offset(0, -1),
            blurRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Debossed Neumorphic text field
            Expanded(
              child: AiTextInputField(
                controller: textController,
                onSubmitted: onSend,
              ),
            ),
            const SizedBox(width: 10),

            // 3D Convex Neumorphic send button
            Obx(
              () => AiSendButton(
                isLoading: isLoading.value,
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
