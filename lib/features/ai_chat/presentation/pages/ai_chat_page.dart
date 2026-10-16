import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/ai_chat_providers.dart';
import '../widgets/ai_chat_app_bar.dart';
import '../widgets/ai_empty_state.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_message_input.dart';
import '../widgets/ai_typing_indicator.dart';

/// Clean Architecture Presentation Page for AI Chat powered by Riverpod.
/// Orchestrates the Neumorphic chat components while keeping UI declarative,
/// clean, and decoupled from low-level widget details.
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handlePromptSelected(String prompt) {
    _textController.text = prompt;
    _handleSend();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(aiChatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _confirmClearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.current.clearChatTitle),
        content: Text(S.current.clearChatConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(S.current.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              S.current.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(aiChatNotifierProvider.notifier).clearChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatNotifierProvider);
    final theme = Theme.of(context);

    ref.listen(aiChatNotifierProvider.select((s) => s.errorMessage), (
      prev,
      next,
    ) {
      if (next != null && next.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    ref.listen(aiChatNotifierProvider.select((s) => s.messages), (prev, next) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AiChatAppBar(
        onClearChat: _confirmClearChat,
      ),
      body: Column(
        children: [
          // Main Messages Area
          Expanded(
            child: chatState.messages.isEmpty
                ? AiEmptyState(
                    onPromptSelected: _handlePromptSelected,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      final isLast = index == chatState.messages.length - 1;

                      return AiMessageBubble(
                        message: message,
                        isLast: isLast,
                        onRetry: () => ref
                            .read(aiChatNotifierProvider.notifier)
                            .retryMessage(message),
                      );
                    },
                  ),
          ),

          // Typing / Streaming Loading Indicator
          if (chatState.isLoading)
            AiTypingIndicator(
              loadingMessage: chatState.loadingMessage,
            ),

          // Neumorphic Input Bar
          AiMessageInput(
            textController: _textController,
            isLoading: chatState.isLoading,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}
