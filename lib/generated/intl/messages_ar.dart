// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(count) => "إضافة ${count} عادات إلى قائمة العادات";

  static String m1(count) =>
      "${Intl.plural(count, one: 'لديك مهمة واحدة متبقية بحاجة للإنجاز اليوم.', two: 'لديك مهمتان متبقيتان بحاجة للإنجاز اليوم.', few: 'لديك ${count} مهام متبقية بحاجة للإنجاز اليوم.', many: 'لديك ${count} مهمة متبقية بحاجة للإنجاز اليوم.', other: 'لديك ${count} مهمة متبقية بحاجة للإنجاز اليوم.')}";

  static String m2(days) => "منذ ${days} يوم";

  static String m3(count) =>
      "هل أنت متأكد من حذف ${count} عادة؟ لا يمكن التراجع عن هذا الإجراء.";

  static String m4(message) => "فشل مسح البيانات: ${message}";

  static String m5(count) => "تم توليد ${count} عادات مخصصة لك";

  static String m6(hours) => "منذ ${hours} ساعة";

  static String m7(count) => "${count} محدد";

  static String m8(minutes) => "منذ ${minutes} دقيقة";

  static String m9(count) => "تمت إضافة ${count} عادات إلى متتبعك بنجاح.";

  static String m10(time) => "تم ضبط التذكير في ${time}";

  static String m11(streak) => "يوم ${streak}";

  static String m12(category) => "خطتك في ${category}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("حول التطبيق"),
        "account": MessageLookupByLibrary.simpleMessage("الحساب"),
        "add": MessageLookupByLibrary.simpleMessage("إضافة"),
        "addFirstHabitSubtitle":
            MessageLookupByLibrary.simpleMessage("أضف عادتك الأولى عبر زر +"),
        "addHabitsToTracker": m0,
        "addNewHabit":
            MessageLookupByLibrary.simpleMessage("إضافة عادة جديدة..."),
        "addedSelectedHabitsSuccess": MessageLookupByLibrary.simpleMessage(
            "تمت إضافة العادات المحددة بنجاح."),
        "aiApiKeySubtitle": MessageLookupByLibrary.simpleMessage(
            "مفتاح Gemini مخصص لميزات الذكاء الاصطناعي"),
        "aiApiKeyTitle":
            MessageLookupByLibrary.simpleMessage("مفتاح الذكاء الاصطناعي"),
        "aiCoach": MessageLookupByLibrary.simpleMessage("المدرب الذكي"),
        "aiGreeting": MessageLookupByLibrary.simpleMessage(
            "أنا هنا لدعمك في رحلتك نحو أهدافك."),
        "alreadyHaveAccount":
            MessageLookupByLibrary.simpleMessage("لديك حساب بالفعل؟"),
        "answerRequired":
            MessageLookupByLibrary.simpleMessage("الإجابة مطلوبة"),
        "apiKeyClearedSuccess": MessageLookupByLibrary.simpleMessage(
            "تمت إزالة المفتاح المخصص والعودة للمفتاح الافتراضي."),
        "apiKeyHint": MessageLookupByLibrary.simpleMessage(
            "الصق مفتاح Gemini الخاص بك (AIza...)"),
        "apiKeySavedSuccess":
            MessageLookupByLibrary.simpleMessage("تم حفظ مفتاح API بنجاح"),
        "appVersionAndInformation":
            MessageLookupByLibrary.simpleMessage("هذا التطبيق من تطوير دكستر"),
        "appearance": MessageLookupByLibrary.simpleMessage("المظهر"),
        "areYouSureYouWantToDeleteThisHabit":
            MessageLookupByLibrary.simpleMessage(
                "هل أنت متأكد من رغبتك في حذف هذه العادة؟"),
        "authErrorDefault": MessageLookupByLibrary.simpleMessage("حدث خطأ"),
        "authErrorEmailInUse": MessageLookupByLibrary.simpleMessage(
            "البريد الإلكتروني مستخدم بالفعل"),
        "authErrorGoogle": MessageLookupByLibrary.simpleMessage(
            "حدث خطأ أثناء تسجيل الدخول بواسطة Google"),
        "authErrorInvalidEmail":
            MessageLookupByLibrary.simpleMessage("البريد الإلكتروني غير صالح"),
        "authErrorNetworkFailed":
            MessageLookupByLibrary.simpleMessage("فشل الاتصال بالإنترنت"),
        "authErrorSignOut":
            MessageLookupByLibrary.simpleMessage("حدث خطأ أثناء تسجيل الخروج"),
        "authErrorTooManyRequests": MessageLookupByLibrary.simpleMessage(
            "محاولات كثيرة جداً، يرجى المحاولة لاحقاً"),
        "authErrorUserNotFound": MessageLookupByLibrary.simpleMessage(
            "لا يوجد مستخدم بهذا البريد الإلكتروني"),
        "authErrorWeakPassword":
            MessageLookupByLibrary.simpleMessage("كلمة المرور ضعيفة جداً"),
        "authErrorWrongPassword":
            MessageLookupByLibrary.simpleMessage("كلمة المرور غير صحيحة"),
        "backToLogin":
            MessageLookupByLibrary.simpleMessage("العودة لتسجيل الدخول"),
        "backupData": MessageLookupByLibrary.simpleMessage("نسخ احتياطي"),
        "barChartIsEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد بيانات متاحة"),
        "camera": MessageLookupByLibrary.simpleMessage("الكاميرا"),
        "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "categoryLearning":
            MessageLookupByLibrary.simpleMessage("تعلم مهارة جديدة"),
        "categoryLearningDesc": MessageLookupByLibrary.simpleMessage(
            "إتقان أي مهارة ترغب بها خطوة بخطوة"),
        "categoryNutrition":
            MessageLookupByLibrary.simpleMessage("التغذية والصحة"),
        "categoryNutritionDesc": MessageLookupByLibrary.simpleMessage(
            "تحسين نظامك الغذائي وتحقيق أهدافك الصحية"),
        "categorySports":
            MessageLookupByLibrary.simpleMessage("الرياضة واللياقة"),
        "categorySportsDesc": MessageLookupByLibrary.simpleMessage(
            "بناء روتين لياقة بدنية منتظم ومستمر"),
        "categoryStudy":
            MessageLookupByLibrary.simpleMessage("الدراسة والتحصيل العلمي"),
        "categoryStudyDesc": MessageLookupByLibrary.simpleMessage(
            "رفع مستوى أدائك وتحصيلك الأكاديمي"),
        "changeAppTheme":
            MessageLookupByLibrary.simpleMessage("تغيير ثيم ولون التطبيق"),
        "chooseColor": MessageLookupByLibrary.simpleMessage("اختر لوناً"),
        "clear": MessageLookupByLibrary.simpleMessage("مسح"),
        "clearAllData":
            MessageLookupByLibrary.simpleMessage("مسح جميع البيانات"),
        "clearAllDataConfirm": MessageLookupByLibrary.simpleMessage(
            "هل أنت متأكد من رغبتك في حذف جميع العادات والإعدادات؟ لا يمكن التراجع عن هذا الإجراء."),
        "clearChatConfirm": MessageLookupByLibrary.simpleMessage(
            "هل أنت متأكد من مسح المحادثة بالكامل؟"),
        "clearChatTitle": MessageLookupByLibrary.simpleMessage("مسح المحادثة"),
        "clearingData":
            MessageLookupByLibrary.simpleMessage("جاري مسح البيانات..."),
        "close": MessageLookupByLibrary.simpleMessage("إغلاق"),
        "cloudSync": MessageLookupByLibrary.simpleMessage("المزامنة السحابية"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("قريباً"),
        "completed": MessageLookupByLibrary.simpleMessage("مكتمل"),
        "completedLabel": MessageLookupByLibrary.simpleMessage("مكتمل"),
        "completionRate": MessageLookupByLibrary.simpleMessage("نسبة الإنجاز"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("تأكيد كلمة المرور"),
        "confirmPasswordRequired":
            MessageLookupByLibrary.simpleMessage("يرجى تأكيد كلمة المرور"),
        "continueButton": MessageLookupByLibrary.simpleMessage("متابعة"),
        "createAccount":
            MessageLookupByLibrary.simpleMessage("إنشاء حساب جديد"),
        "currentlySelected":
            MessageLookupByLibrary.simpleMessage("المحدد حالياً"),
        "customApiKeyActive":
            MessageLookupByLibrary.simpleMessage("المفتاح المخصص مفعّل"),
        "customApiKeyDialogDesc": MessageLookupByLibrary.simpleMessage(
            "يمكنك إدخال مفتاح API الخاص بك من Google Gemini لاستخدامه بدل المفتاح الافتراضي."),
        "customApiKeyDialogTitle":
            MessageLookupByLibrary.simpleMessage("مفتاح Gemini API"),
        "dailyReminder": MessageLookupByLibrary.simpleMessage("التذكير اليومي"),
        "dailyReminderAllCompleted": MessageLookupByLibrary.simpleMessage(
            "رائع جداً! لقد أكملت جميع مهامك اليوم بنجاح."),
        "dailyReminderBody": MessageLookupByLibrary.simpleMessage(
            "حان وقت التحقق من عاداتك اليومية!"),
        "dailyReminderNoTasks": MessageLookupByLibrary.simpleMessage(
            "لا توجد مهام مسجلة بعد، ابدأ بإضافة عاداتك اليومية."),
        "dailyReminderPendingTasks": m1,
        "dailyReminderTitle":
            MessageLookupByLibrary.simpleMessage("متتبع العادات"),
        "dataClearedSuccess": MessageLookupByLibrary.simpleMessage(
            "تم مسح البيانات بنجاح! جاري إعادة تشغيل التطبيق..."),
        "daysAgo": m2,
        "defaultApiKeyActive":
            MessageLookupByLibrary.simpleMessage("المفتاح الافتراضي نشط"),
        "defaultHabits1": MessageLookupByLibrary.simpleMessage("انقر هنا"),
        "defaultHabits2":
            MessageLookupByLibrary.simpleMessage("<== اسحب لليسار للتعديل"),
        "defaultHabits3":
            MessageLookupByLibrary.simpleMessage("اسحب لليمين للحذف ==>"),
        "delete": MessageLookupByLibrary.simpleMessage("حذف"),
        "deleteAllHabitsAndSettings":
            MessageLookupByLibrary.simpleMessage("حذف جميع العادات والإعدادات"),
        "deleteHabit": MessageLookupByLibrary.simpleMessage("حذف العادة"),
        "deleteSelected": MessageLookupByLibrary.simpleMessage("حذف المحدد"),
        "deleteSelectedConfirm": m3,
        "detectedHabits":
            MessageLookupByLibrary.simpleMessage("العادات المكتشفة"),
        "dontHaveAccount":
            MessageLookupByLibrary.simpleMessage("ليس لديك حساب؟"),
        "drawer": MessageLookupByLibrary.simpleMessage(""),
        "drawerReat": MessageLookupByLibrary.simpleMessage("الإحصائيات"),
        "drawerSetting": MessageLookupByLibrary.simpleMessage("الإعدادات"),
        "drawerTheme": MessageLookupByLibrary.simpleMessage("لون الثيم"),
        "editThisHabit":
            MessageLookupByLibrary.simpleMessage("تعديل هذه العادة"),
        "email": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
        "emailInvalid": MessageLookupByLibrary.simpleMessage(
            "يرجى إدخال بريد إلكتروني صالح"),
        "emailRequired": MessageLookupByLibrary.simpleMessage(
            "يرجى إدخال البريد الإلكتروني"),
        "error": MessageLookupByLibrary.simpleMessage("خطأ"),
        "exportYourHabitData":
            MessageLookupByLibrary.simpleMessage("تصدير بيانات العادات"),
        "failedToClearData": m4,
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("نسيت كلمة المرور؟"),
        "gallery": MessageLookupByLibrary.simpleMessage("المعرض"),
        "geminiApiKeyError": MessageLookupByLibrary.simpleMessage(
            "خطأ في إعدادات مفتاح API الخاص بـ Gemini."),
        "geminiQuotaExceeded": MessageLookupByLibrary.simpleMessage(
            "تم تجاوز حد الطلبات المسموح به. يرجى المحاولة بعد قليل."),
        "geminiServerError":
            MessageLookupByLibrary.simpleMessage("حدث خطأ في خادم Gemini."),
        "generateMyPlan": MessageLookupByLibrary.simpleMessage("إنشاء خطتي ✨"),
        "generatePlan": MessageLookupByLibrary.simpleMessage("إنشاء خطة عادات"),
        "generatePlanSubtitle": MessageLookupByLibrary.simpleMessage(
            "اختر مجالاً وسنقوم بإنشاء خطة عادات مخصصة تناسبك تماماً."),
        "generatePlanTitle":
            MessageLookupByLibrary.simpleMessage("ما الذي تريد\nالعمل عليه؟"),
        "getKeyInfo": MessageLookupByLibrary.simpleMessage(
            "احصل على مفتاح مجاني من Google AI Studio"),
        "habitsGeneratedCount": m5,
        "hambitstate": MessageLookupByLibrary.simpleMessage("حالة العادة"),
        "hoursAgo": m6,
        "importPreviouslyExportedData": MessageLookupByLibrary.simpleMessage(
            "استيراد بيانات محفوظة مسبقاً"),
        "incomplete": MessageLookupByLibrary.simpleMessage("غير مكتمل"),
        "initialGreeting": MessageLookupByLibrary.simpleMessage(
            "مرحبا. يرجى التعريف بنفسك باختصار كمدرب ذكاء اصطناعي خاص بي والتعليق على تقدم عاداتي اليوم."),
        "invalidApiKeyFormat":
            MessageLookupByLibrary.simpleMessage("يرجى إدخال مفتاح API صالح"),
        "isEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد عادات مسجلة بعد"),
        "itemsSelected": m7,
        "joinUs": MessageLookupByLibrary.simpleMessage("انضم إلينا"),
        "justAMoment": MessageLookupByLibrary.simpleMessage("لحظة واحدة"),
        "justNow": MessageLookupByLibrary.simpleMessage("الآن"),
        "lan": MessageLookupByLibrary.simpleMessage("اللغة"),
        "lastSync": MessageLookupByLibrary.simpleMessage("آخر مزامنة"),
        "loadingHabits":
            MessageLookupByLibrary.simpleMessage("جاري تحميل عاداتك..."),
        "login": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
        "loginRequired":
            MessageLookupByLibrary.simpleMessage("يرجى تسجيل الدخول أولاً"),
        "loginToAccount": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
        "loginToEnableSync": MessageLookupByLibrary.simpleMessage(
            "سجل الدخول لتفعيل المزامنة والنسخ الاحتياطي"),
        "logout": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
        "logoutConfirmMessage": MessageLookupByLibrary.simpleMessage(
            "هل أنت متأكد من تسجيل الدخول؟"),
        "logoutConfirmTitle":
            MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
        "logoutFromAccount":
            MessageLookupByLibrary.simpleMessage("الخروج من حسابك"),
        "minutesAgo": m8,
        "monthly": MessageLookupByLibrary.simpleMessage("تقدم الشهري"),
        "name": MessageLookupByLibrary.simpleMessage("الاسم"),
        "nameRequired":
            MessageLookupByLibrary.simpleMessage("يرجى إدخال الاسم"),
        "noHabitsDetected":
            MessageLookupByLibrary.simpleMessage("لم يتم العثور على عادات"),
        "noHabitsDetectedDesc": MessageLookupByLibrary.simpleMessage(
            "لم نتمكن من العثور على أي مهام أو عادات واضحة في هذه الصورة. يرجى تجربة صورة أخرى."),
        "noHabitsYet":
            MessageLookupByLibrary.simpleMessage("لا توجد عادات بعد"),
        "notSyncedYet":
            MessageLookupByLibrary.simpleMessage("لم تتم المزامنة بعد"),
        "notificationTestSent": MessageLookupByLibrary.simpleMessage(
            "تم إرسال إشعار تجريبي! تفقد شريط الإشعارات."),
        "notificationTestTitle":
            MessageLookupByLibrary.simpleMessage("تجربة الإشعار"),
        "notifications": MessageLookupByLibrary.simpleMessage("الإشعارات"),
        "notificationsDisabled":
            MessageLookupByLibrary.simpleMessage("تم تعطيل الإشعارات"),
        "online": MessageLookupByLibrary.simpleMessage("متصل"),
        "optional": MessageLookupByLibrary.simpleMessage("اختياري"),
        "or": MessageLookupByLibrary.simpleMessage("أو"),
        "password": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
        "passwordMismatch":
            MessageLookupByLibrary.simpleMessage("كلمة المرور غير متطابقة"),
        "passwordRequired":
            MessageLookupByLibrary.simpleMessage("يرجى إدخال كلمة المرور"),
        "passwordTooShort": MessageLookupByLibrary.simpleMessage(
            "كلمة المرور يجب أن تكون 6 أحرف على الأقل"),
        "paste": MessageLookupByLibrary.simpleMessage("لصق"),
        "pending": MessageLookupByLibrary.simpleMessage("قيد الانتظار"),
        "pieChartIsEmpty":
            MessageLookupByLibrary.simpleMessage("لا توجد عادات لعرضها"),
        "planActivatedDesc": m9,
        "planActivatedTitle":
            MessageLookupByLibrary.simpleMessage("🎉 تم تفعيل الخطة!"),
        "planGenerationFailed": MessageLookupByLibrary.simpleMessage(
            "فشل إنشاء الخطة. يرجى المحاولة مجدداً."),
        "pleaseAnswerToContinue": MessageLookupByLibrary.simpleMessage(
            "يرجى الإجابة عن هذا السؤال للمتابعة."),
        "ratepagetitle":
            MessageLookupByLibrary.simpleMessage("إحصائيات العادات"),
        "reminderSetFor": m10,
        "remindersEnabledBody": MessageLookupByLibrary.simpleMessage(
            "ستصلك إشعارات متابعة عاداتك اليومية."),
        "remindersEnabledTitle":
            MessageLookupByLibrary.simpleMessage("تم تفعيل التذكيرات!"),
        "resetPassword":
            MessageLookupByLibrary.simpleMessage("إعادة تعيين كلمة المرور"),
        "resetPasswordDescription": MessageLookupByLibrary.simpleMessage(
            "أدخل بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور"),
        "resetPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني"),
        "resetPasswordTitle":
            MessageLookupByLibrary.simpleMessage("إعادة تعيين كلمة المرور"),
        "resetToDefault":
            MessageLookupByLibrary.simpleMessage("استعادة المفتاح الافتراضي"),
        "restoreData": MessageLookupByLibrary.simpleMessage("استعادة البيانات"),
        "restoreFeatureWillBeAvailableInFutureUpdates":
            MessageLookupByLibrary.simpleMessage(
                "ستتوفر ميزة الاستعادة في التحديثات القادمة"),
        "retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
        "save": MessageLookupByLibrary.simpleMessage("حفظ"),
        "saveSelected": MessageLookupByLibrary.simpleMessage("حفظ المحدد"),
        "scanHabitsDesc": MessageLookupByLibrary.simpleMessage(
            "استخراج المهام من الصورة تلقائياً."),
        "scanHabitsTitle": MessageLookupByLibrary.simpleMessage("مسح العادات"),
        "scanImage": MessageLookupByLibrary.simpleMessage("مسح الصورة"),
        "selectAll": MessageLookupByLibrary.simpleMessage("تحديد الكل"),
        "selectAtLeastOneHabit":
            MessageLookupByLibrary.simpleMessage("اختر عادة واحدة على الأقل"),
        "sendResetLink":
            MessageLookupByLibrary.simpleMessage("إرسال رابط إعادة التعيين"),
        "setDailyReminder":
            MessageLookupByLibrary.simpleMessage("تعيين تذكير يومي للعادات"),
        "settingPageTitle": MessageLookupByLibrary.simpleMessage("الإعدادات"),
        "signInWithGoogle":
            MessageLookupByLibrary.simpleMessage("تسجيل الدخول بواسطة Google"),
        "signUpWithGoogle":
            MessageLookupByLibrary.simpleMessage("التسجيل بواسطة Google"),
        "signup": MessageLookupByLibrary.simpleMessage("إنشاء حساب"),
        "skipNow": MessageLookupByLibrary.simpleMessage("تخطي الآن"),
        "somethingWentWrong":
            MessageLookupByLibrary.simpleMessage("حدث خطأ ما"),
        "streak": MessageLookupByLibrary.simpleMessage("الاستمرارية"),
        "streakDay": m11,
        "success": MessageLookupByLibrary.simpleMessage("معدل النجاح"),
        "summary": MessageLookupByLibrary.simpleMessage("ملخص العادات"),
        "syncError": MessageLookupByLibrary.simpleMessage("فشلت المزامنة"),
        "syncFailed": MessageLookupByLibrary.simpleMessage("فشلت المزامنة"),
        "syncNow": MessageLookupByLibrary.simpleMessage("مزامنة الآن"),
        "syncSuccess":
            MessageLookupByLibrary.simpleMessage("تمت المزامنة بنجاح"),
        "syncing": MessageLookupByLibrary.simpleMessage("جاري المزامنة..."),
        "systemLanguage": MessageLookupByLibrary.simpleMessage("لغة النظام"),
        "tapToApply": MessageLookupByLibrary.simpleMessage("اضغط للتطبيق"),
        "tapToEdit": MessageLookupByLibrary.simpleMessage("اضغط للإعداد"),
        "testNotification":
            MessageLookupByLibrary.simpleMessage("تجربة الإشعار"),
        "testNotificationDesc": MessageLookupByLibrary.simpleMessage(
            "إرسال إشعار فوري للتحقق من عمل الإشعارات"),
        "theFieldCantBeEmpty":
            MessageLookupByLibrary.simpleMessage("لا يمكن ترك الحقل فارغاً"),
        "themeNotFound":
            MessageLookupByLibrary.simpleMessage("الثيم غير موجود"),
        "themepage": MessageLookupByLibrary.simpleMessage("تخصيص الثيم"),
        "themepagetitle": MessageLookupByLibrary.simpleMessage("إعدادات الثيم"),
        "today": MessageLookupByLibrary.simpleMessage("تقدم اليوم"),
        "tooltipItem": MessageLookupByLibrary.simpleMessage("نفذه الآن"),
        "tooltipItemCompleted":
            MessageLookupByLibrary.simpleMessage("تم إنجازه"),
        "total": MessageLookupByLibrary.simpleMessage("المجموع"),
        "trendChartIsEmpty": MessageLookupByLibrary.simpleMessage(
            "بيانات غير كافية لعرض الإحصائيات"),
        "tryAgain": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
        "typeMessage": MessageLookupByLibrary.simpleMessage("اكتب رسالة..."),
        "unexpectedError":
            MessageLookupByLibrary.simpleMessage("حدث خطأ غير متوقع."),
        "user": MessageLookupByLibrary.simpleMessage("مستخدم"),
        "weekly": MessageLookupByLibrary.simpleMessage("تقدم الأسبوعي"),
        "yourPlanTitle": m12
      };
}
