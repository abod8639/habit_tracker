import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/neumorphic_input.dart';
import 'package:habit_tracker/core/utils/number_utils.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/plan_generator_providers.dart';

class QuestionNumberInput extends ConsumerStatefulWidget {
  final QuestionEntity question;

  const QuestionNumberInput({
    super.key,
    required this.question,
  });

  @override
  ConsumerState<QuestionNumberInput> createState() => _QuestionNumberInputState();
}

class _QuestionNumberInputState extends ConsumerState<QuestionNumberInput> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final initialAnswer =
        ref.read(planGeneratorNotifierProvider).getAnswer(widget.question.id);
    _textController = TextEditingController(
      text: initialAnswer?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.isNotEmpty && widget.question.maxValue != null) {
      final parsed = tryParseNormalizedNum(value);
      if (parsed != null && parsed > widget.question.maxValue!) {
        final clamped = widget.question.maxValue!.toString();
        _textController.value = TextEditingValue(
          text: clamped,
          selection: TextSelection.collapsed(offset: clamped.length),
        );
        ref
            .read(planGeneratorNotifierProvider.notifier)
            .setAnswer(widget.question.id, clamped);
        return;
      }
    }
    ref
        .read(planGeneratorNotifierProvider.notifier)
        .setAnswer(widget.question.id, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = ref.watch(
      planGeneratorNotifierProvider.select((s) => s.selectedCategory?.color),
    );
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeumorphicInput(
          controller: _textController,
          onChanged: _onChanged,
          hintText: widget.question.hint ?? '0',
          unit: widget.question.unit,
          accentColor: color,
          isNumber: true,
          autofocus: true,
          textAlign: TextAlign.center,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]')),
            if (widget.question.maxValue != null)
              _MaxNumberInputFormatter(widget.question.maxValue!),
          ],
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        if (widget.question.maxValue != null) ...[
          const SizedBox(height: 10),
          Text(
            isArabic
                ? 'الحد الأقصى: ${widget.question.maxValue} ${widget.question.unit ?? ''}'.trim()
                : 'Maximum: ${widget.question.maxValue} ${widget.question.unit ?? ''}'.trim(),
            style: TextStyle(
              fontSize: 13,
              color: theme.hintColor.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _MaxNumberInputFormatter extends TextInputFormatter {
  final num maxValue;

  const _MaxNumberInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final parsed = tryParseNormalizedNum(newValue.text);
    if (parsed == null) return oldValue;
    if (parsed > maxValue) {
      final clamped = maxValue.toString();
      return TextEditingValue(
        text: clamped,
        selection: TextSelection.collapsed(offset: clamped.length),
      );
    }
    return newValue;
  }
}
