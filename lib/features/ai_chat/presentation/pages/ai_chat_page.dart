import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/ai_chat_providers.dart';
import '../widgets/ai_chat_app_bar.dart';
import '../widgets/ai_chat_error_view.dart';
import '../widgets/ai_empty_state.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/ai_message_input.dart';
import '../widgets/ai_typing_indicator.dart';

/// Clean Architecture Presentation Page for AI Chat powered by Riverpod AsyncNotifier.
/// Orchestrates the Neumorphic chat components while utilizing AsyncValue.when for robust
/// error boundaries and zero-crash fallback states.
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
    final asyncChatState = ref.watch(aiChatNotifierProvider);
    final theme = Theme.of(context);

    // Listen to transient messaging failures and present elegant SnackBars
    ref.listen<Failure?>(
      aiChatNotifierProvider.select((s) => s.value?.activeFailure),
      (prev, nextFailure) {
        if (nextFailure != null && mounted) {
          final errorMessage = nextFailure.toMessage();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
    );

    // Auto-scroll when messages count updates
    ref.listen<int?>(
      aiChatNotifierProvider.select((s) => s.value?.messages.length),
      (prev, next) {
        if (next != null && next != prev) {
          _scrollToBottom();
        }
      },
    );


    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AiChatAppBar(
        onClearChat: _confirmClearChat,
      ),
      body: asyncChatState.when(
        loading: () => Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
        error: (error, _) => AiChatErrorView(
          errorMessage: error.toString(),
          onRetry: () => ref.invalidate(aiChatNotifierProvider),
        ),
        data: (chatState) {
          return Column(
            children: [
              // Main Messages View
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

              // Streaming / Typing indicator with status message
              if (chatState.isStreaming)
                AiTypingIndicator(
                  loadingMessage: chatState.statusMessage,
                ),

              // Neumorphic Input Dock
              AiMessageInput(
                textController: _textController,
                isLoading: chatState.isStreaming,
                onSend: _handleSend,
              ),
            ],
          );
        },
      ),
    );
  }
}
