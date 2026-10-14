import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';

class LangState {
  final String languageCode;
  final Locale effectiveLocale;

  const LangState({
    required this.languageCode,
    required this.effectiveLocale,
  });

  bool get isArabic => effectiveLocale.languageCode == 'ar';

  LangState copyWith({
    String? languageCode,
    Locale? effectiveLocale,
  }) {
    return LangState(
      languageCode: languageCode ?? this.languageCode,
      effectiveLocale: effectiveLocale ?? this.effectiveLocale,
    );
  }
}

class LangNotifier extends Notifier<LangState> {
  static Locale resolveLocale(String code) {
    if (code == 'ar') return const Locale('ar');
    if (code == 'en') return const Locale('en');
    final deviceLocale = PlatformDispatcher.instance.locale;
    return deviceLocale.languageCode == 'ar'
        ? const Locale('ar')
        : const Locale('en');
  }

  @override
  LangState build() {
    final langStorage = ref.watch(langStorageServiceProvider);
    final savedCode = langStorage.getCurrentLanguage();
    final effective = resolveLocale(savedCode);

    return LangState(
      languageCode: savedCode,
      effectiveLocale: effective,
    );
  }

  Future<void> changeLanguage(String lang) async {
    final saveUseCase = ref.read(saveLanguageUseCaseProvider);
    final result = await saveUseCase(lang);
    await result.fold(
      (failure) async {},
      (_) async {
        final newEffective = resolveLocale(lang);
        await S.load(newEffective);
        Intl.defaultLocale = newEffective.languageCode;
        state = LangState(
          languageCode: lang,
          effectiveLocale: newEffective,
        );
      },
    );
  }
}

final langNotifierProvider = NotifierProvider<LangNotifier, LangState>(() {
  return LangNotifier();
});
