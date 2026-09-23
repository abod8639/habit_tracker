import 'dart:ui';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/usecases/get_language_usecase.dart';
import '../../domain/usecases/save_language_usecase.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/generated/l10n.dart';

class LangController extends GetxController {
  final GetLanguageUseCase _getLanguageUseCase = Get.find();
  final SaveLanguageUseCase _saveLanguageUseCase = Get.find();

  var language = LangStorage.defaultLanguage.obs;

  Locale get effectiveLocale {
    final code = language.value;
    if (code == 'ar') return const Locale('ar');
    if (code == 'en') return const Locale('en');
    final deviceLocale = PlatformDispatcher.instance.locale;
    if (deviceLocale.languageCode == 'ar') {
      return const Locale('ar');
    }
    return const Locale('en');
  }

  bool get isArabic => effectiveLocale.languageCode == 'ar';

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final result = await _getLanguageUseCase();
    result.fold(
      (failure) {
        language.value = LangStorage.defaultLanguage;
        _applyLocale(effectiveLocale);
      },
      (langCode) {
        language.value = langCode;
        _applyLocale(effectiveLocale);
      },
    );
  }

  Future<void> changeLanguage(String lang) async {
    final result = await _saveLanguageUseCase(lang);
    result.fold(
      (failure) {
        // debugPrint('Error saving language: ${failure.message}');
      },
      (_) async {
        language.value = lang;
        await _applyLocale(effectiveLocale);
      },
    );
  }

  Future<void> _applyLocale(Locale locale) async {
    await S.load(locale);
    Intl.defaultLocale = locale.languageCode;
    Get.updateLocale(locale);
  }
}
