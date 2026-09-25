import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/ai_chat/presentation/controllers/ai_chat_controller.dart';
import '../widgets/ai_chat_app_bar.dart';
import '../widgets/ai_empty_state.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_message_input.dart';
import '../widgets/ai_typing_indicator.dart';

/// Clean Architecture Presentation Page for AI Chat.
/// Orchestrates the Neumorphic chat components while keeping UI declarative,
/// clean, and decoupled from low-level widget details.
class AiChatPage extends GetView<AiChatController> {
  const AiChatPage({super.key});

  void _handlePromptSelected(String prompt) {
    controller.textController.text = prompt;
    controller.sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AiChatAppBar(
        onClearChat: () => controller.clearChat(),
      ),
      body: Column(
        children: [
          // Main Messages Area
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return AiEmptyState(
                  onPromptSelected: _handlePromptSelected,
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isLast = index == controller.messages.length - 1;

                  return AiMessageBubble(
                    message: message,
                    isLast: isLast,
                    onRetry: () => controller.retryMessage(message),
                  );
                },
              );
            }),
          ),

          // Typing / Streaming Loading Indicator
          Obx(
            () => controller.isLoading.value
                ? AiTypingIndicator(
                    loadingMessage: controller.loadingMessage,
                  )
                : const SizedBox.shrink(),
          ),

          // Neumorphic Input Bar
          AiMessageInput(
            textController: controller.textController,
            isLoading: controller.isLoading,
            onSend: controller.sendMessage,
          ),
        ],
      ),
    );
  }
}
