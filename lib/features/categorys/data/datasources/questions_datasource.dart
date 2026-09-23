import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/lang_controller.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/question_entity.dart';

/// Static data source — replace with a remote config or CMS later if needed.
class QuestionsDataSource {
  QuestionsDataSource._();

  static bool get _isArabic {
    if (Get.isRegistered<LangController>()) {
      return Get.find<LangController>().isArabic;
    }
    final loc = Get.locale?.languageCode ?? Intl.getCurrentLocale();
    return loc.startsWith('ar');
  }

  static List<QuestionEntity> forCategory(PlanCategory category) {
    if (_isArabic) {
      switch (category) {
        case PlanCategory.nutrition:
          return _nutritionAr;
        case PlanCategory.sports:
          return _sportsAr;
        case PlanCategory.study:
          return _studyAr;
        case PlanCategory.learning:
          return _learningAr;
      }
    } else {
      switch (category) {
        case PlanCategory.nutrition:
          return _nutritionEn;
        case PlanCategory.sports:
          return _sportsEn;
        case PlanCategory.study:
          return _studyEn;
        case PlanCategory.learning:
          return _learningEn;
      }
    }
  }

  // ─── NUTRITION (ARABIC) ────────────────────────────────────────────────────
  static const List<QuestionEntity> _nutritionAr = [
    QuestionEntity(
      id: 'age',
      text: 'كم عمرك؟',
      type: QuestionType.number,
      hint: '25',
      unit: 'سنة',
    ),
    QuestionEntity(
      id: 'weight',
      text: 'ما هو وزنك الحالي؟',
      type: QuestionType.number,
      hint: '75',
      unit: 'كجم',
    ),
    QuestionEntity(
      id: 'height',
      text: 'ما هو طولك؟',
      type: QuestionType.number,
      hint: '175',
      unit: 'سم',
    ),
    QuestionEntity(
      id: 'goal',
      text: 'ما هو هدفك الغذائي الأساسي؟',
      type: QuestionType.singleChoice,
      choices: [
        'خسارة الوزن',
        'بناء الكتلة العضلية',
        'الحفاظ على الوزن الحالي',
        'زيادة مستويات الطاقة والنشاط',
        'تناول طعام صحي بشكل عام',
      ],
    ),
    QuestionEntity(
      id: 'activity_level',
      text: 'ما هو مستوى نشاطك خلال اليوم؟',
      type: QuestionType.singleChoice,
      choices: [
        'خامل (عمل مكتبي، حركة قليلة)',
        'نشاط خفيف (مشي خفيف)',
        'نشاط متوسط (تمارين 2–3 مرات أسبوعياً)',
        'نشط جداً (تمارين 5+ مرات أسبوعياً)',
      ],
    ),
    QuestionEntity(
      id: 'dietary_restrictions',
      text: 'هل لديك أي قيود أو تفضيلات غذائية خاصة؟',
      subtitle: 'اختر كل ما ينطبق',
      type: QuestionType.multipleChoice,
      choices: [
        'لا يوجد',
        'نباتي',
        'نباتي صرف (فيجان)',
        'خالٍ من الغلوتين',
        'خالٍ من اللاكتوز',
        'حلال',
        'قليل الكربوهيدرات / كيتو',
      ],
    ),
    QuestionEntity(
      id: 'water_intake',
      text: 'كم كمية الماء التي تشربها يومياً حالياً؟',
      type: QuestionType.singleChoice,
      choices: [
        'أقل من لتر واحد',
        '1–2 لتر',
        'أكثر من 2 لتر',
      ],
    ),
    QuestionEntity(
      id: 'meals_per_day',
      text: 'كم عدد الوجبات التي تتناولها يومياً في العادة؟',
      type: QuestionType.singleChoice,
      choices: ['1–2 وجبات', '3 وجبات', '4–5 وجبات', '6+ وجبات صغيرة'],
    ),
  ];

  // ─── NUTRITION (ENGLISH) ───────────────────────────────────────────────────
  static const List<QuestionEntity> _nutritionEn = [
    QuestionEntity(
      id: 'age',
      text: 'How old are you?',
      type: QuestionType.number,
      hint: '25',
      unit: 'years',
    ),
    QuestionEntity(
      id: 'weight',
      text: 'What is your current weight?',
      type: QuestionType.number,
      hint: '75',
      unit: 'kg',
    ),
    QuestionEntity(
      id: 'height',
      text: 'What is your height?',
      type: QuestionType.number,
      hint: '175',
      unit: 'cm',
    ),
    QuestionEntity(
      id: 'goal',
      text: 'What is your main nutrition goal?',
      type: QuestionType.singleChoice,
      choices: [
        'Lose weight',
        'Gain muscle mass',
        'Maintain current weight',
        'Improve energy levels',
        'Eat healthier overall',
      ],
    ),
    QuestionEntity(
      id: 'activity_level',
      text: 'How active are you during the day?',
      type: QuestionType.singleChoice,
      choices: [
        'Sedentary (desk job, little movement)',
        'Lightly active (short walks)',
        'Moderately active (exercise 2–3x/week)',
        'Very active (exercise 5+x/week)',
      ],
    ),
    QuestionEntity(
      id: 'dietary_restrictions',
      text: 'Do you have any dietary restrictions?',
      subtitle: 'Select all that apply',
      type: QuestionType.multipleChoice,
      choices: [
        'None',
        'Vegetarian',
        'Vegan',
        'Gluten-free',
        'Lactose-free',
        'Halal',
        'Low-carb / Keto',
      ],
    ),
    QuestionEntity(
      id: 'water_intake',
      text: 'How much water do you currently drink per day?',
      type: QuestionType.singleChoice,
      choices: [
        'Less than 1 liter',
        '1–2 liters',
        'More than 2 liters',
      ],
    ),
    QuestionEntity(
      id: 'meals_per_day',
      text: 'How many meals do you typically eat per day?',
      type: QuestionType.singleChoice,
      choices: ['1–2 meals', '3 meals', '4–5 meals', '6+ small meals'],
    ),
  ];

  // ─── SPORTS (ARABIC) ───────────────────────────────────────────────────────
  static const List<QuestionEntity> _sportsAr = [
    QuestionEntity(
      id: 'age',
      text: 'كم عمرك؟',
      type: QuestionType.number,
      hint: '25',
      unit: 'سنة',
    ),
    QuestionEntity(
      id: 'fitness_level',
      text: 'كيف تصف مستوى لياقتك البدنية الحالي؟',
      type: QuestionType.singleChoice,
      choices: [
        'مبتدئ — نادراً ما أمارس الرياضة',
        'متوسط — أمارس الرياضة 1–2 مرة أسبوعياً',
        'نشط — أمارس الرياضة 3–4 مرات أسبوعياً',
        'متقدم — أمارس الرياضة 5+ مرات أسبوعياً',
      ],
    ),
    QuestionEntity(
      id: 'goal',
      text: 'ما هو هدفك الرياضي الرئيسي؟',
      type: QuestionType.singleChoice,
      choices: [
        'خسارة الوزن / حرق الدهون',
        'بناء الكتلة العضلية',
        'تحسين صحة القلب واللياقة العامة',
        'زيادة المرونة وتوازن الحركة',
        'التدريب لرياضة معينة',
        'لياقة ونشاط عام',
      ],
    ),
    QuestionEntity(
      id: 'available_days',
      text: 'كم يوماً في الأسبوع يمكنك ممارسة التمارين فيه؟',
      type: QuestionType.singleChoice,
      choices: ['1–2 أيام', '3–4 أيام', '5–6 أيام', 'كل يوم'],
    ),
    QuestionEntity(
      id: 'session_duration',
      text: 'كم المدة المتاحة لديك لكل حصة تدريبية؟',
      type: QuestionType.singleChoice,
      choices: [
        '15–30 دقيقة',
        '30–45 دقيقة',
        '45–60 دقيقة',
        'أكثر من 60 دقيقة',
      ],
    ),
    QuestionEntity(
      id: 'equipment',
      text: 'ما هي الأدوات أو المرافق المتاحة لديك؟',
      subtitle: 'اختر كل ما ينطبق',
      type: QuestionType.multipleChoice,
      choices: [
        'نادي رياضي متكامل (جيم)',
        'أوزان منزلية وأربطة مقاومة',
        'أماكن مفتوحة (حديقة، مضمار جري)',
        'مسبح',
        'بدون أدوات (وزن الجسم فقط)',
      ],
    ),
    QuestionEntity(
      id: 'limitations',
      text: 'هل تعاني من أي إصابات أو قيود بدنية؟',
      type: QuestionType.text,
      hint: 'مثال: ألم بالركبة، أسفل الظهر، أو اكتب لا يوجد',
      isRequired: false,
    ),
  ];

  // ─── SPORTS (ENGLISH) ──────────────────────────────────────────────────────
  static const List<QuestionEntity> _sportsEn = [
    QuestionEntity(
      id: 'age',
      text: 'How old are you?',
      type: QuestionType.number,
      hint: '25',
      unit: 'years',
    ),
    QuestionEntity(
      id: 'fitness_level',
      text: 'How would you describe your current fitness level?',
      type: QuestionType.singleChoice,
      choices: [
        'Beginner — rarely exercise',
        'Intermediate — exercise 1–2x/week',
        'Active — exercise 3–4x/week',
        'Advanced — exercise 5+x/week',
      ],
    ),
    QuestionEntity(
      id: 'goal',
      text: 'What is your main fitness goal?',
      type: QuestionType.singleChoice,
      choices: [
        'Lose weight / burn fat',
        'Build muscle mass',
        'Improve cardiovascular health',
        'Increase flexibility & mobility',
        'Train for a specific sport',
        'General fitness & wellness',
      ],
    ),
    QuestionEntity(
      id: 'available_days',
      text: 'How many days per week can you exercise?',
      type: QuestionType.singleChoice,
      choices: ['1–2 days', '3–4 days', '5–6 days', 'Every day'],
    ),
    QuestionEntity(
      id: 'session_duration',
      text: 'How long can each session be?',
      type: QuestionType.singleChoice,
      choices: [
        '15–30 minutes',
        '30–45 minutes',
        '45–60 minutes',
        '60+ minutes',
      ],
    ),
    QuestionEntity(
      id: 'equipment',
      text: 'What equipment or facilities do you have access to?',
      subtitle: 'Select all that apply',
      type: QuestionType.multipleChoice,
      choices: [
        'Full commercial gym',
        'Home weights & resistance bands',
        'Outdoor spaces (park, track)',
        'Swimming pool',
        'No equipment (bodyweight only)',
      ],
    ),
    QuestionEntity(
      id: 'limitations',
      text: 'Do you have any physical limitations or injuries?',
      type: QuestionType.text,
      hint: 'e.g., knee pain, lower back issues, or type None',
      isRequired: false,
    ),
  ];

  // ─── STUDY (ARABIC) ────────────────────────────────────────────────────────
  static const List<QuestionEntity> _studyAr = [
    QuestionEntity(
      id: 'subject',
      text: 'ما هي المادة أو المجال الذي تدرسه؟',
      type: QuestionType.text,
      hint: 'مثال: الرياضيات، علوم الحاسب، التاريخ',
    ),
    QuestionEntity(
      id: 'current_level',
      text: 'ما هو مستواك الحالي في هذه المادة؟',
      type: QuestionType.singleChoice,
      choices: [
        'مبتدئ تماماً',
        'ملم بالأساسيات',
        'متوسط',
        'متقدم',
      ],
    ),
    QuestionEntity(
      id: 'goal',
      text: 'ما هو هدفك الدراسي؟',
      type: QuestionType.text,
      hint: 'مثال: اجتياز اختبار، نيل شهادة، شغف واهتمام شخصي',
    ),
    QuestionEntity(
      id: 'available_hours',
      text: 'كم ساعة يومياً يمكنك تخصيصها للمذاكرة؟',
      type: QuestionType.singleChoice,
      choices: [
        'أقل من ساعة',
        '1–2 ساعة',
        '2–4 ساعات',
        '4+ ساعات',
      ],
    ),
    QuestionEntity(
      id: 'study_style',
      text: 'ما هي أساليب التعلم الأكثر فاعلية بالنسبة لك؟',
      subtitle: 'اختر كل ما ينطبق',
      type: QuestionType.multipleChoice,
      choices: [
        'قراءة الكتب والملخصات',
        'مشاهدة المحاضرات المرئية',
        'حل المسائل والتمارين العملية',
        'البطاقات التعليمية والتكرار المتباعد',
        'جلسات المذاكرة الجماعية',
        'الشرح والتعليم للآخرين',
      ],
    ),
    QuestionEntity(
      id: 'challenge',
      text: 'ما هو التحدي الأكبر الذي يواجهك في الدراسة؟',
      type: QuestionType.singleChoice,
      choices: [
        'الحفاظ على التركيز',
        'التسويف والمماطلة',
        'فهم المفاهيم المعقدة',
        'إدارة وتنظيم الوقت',
        'تثبيت واسترجاع المعلومات',
      ],
    ),
    QuestionEntity(
      id: 'deadline',
      text: 'هل لديك موعد نهائي أو اختبار قريب؟',
      type: QuestionType.singleChoice,
      choices: [
        'لا يوجد موعد نهائي',
        'خلال شهر',
        'خلال 1–3 أشهر',
        'أكثر من 3 أشهر',
      ],
      isRequired: false,
    ),
  ];

  // ─── STUDY (ENGLISH) ───────────────────────────────────────────────────────
  static const List<QuestionEntity> _studyEn = [
    QuestionEntity(
      id: 'subject',
      text: 'What subject are you studying?',
      type: QuestionType.text,
      hint: 'e.g., Mathematics, Computer Science, History',
    ),
    QuestionEntity(
      id: 'current_level',
      text: 'What is your current level in this subject?',
      type: QuestionType.singleChoice,
      choices: [
        'Complete beginner',
        'Familiar with the basics',
        'Intermediate',
        'Advanced',
      ],
    ),
    QuestionEntity(
      id: 'goal',
      text: 'What is your study goal?',
      type: QuestionType.text,
      hint: 'e.g., Pass an exam, complete a degree, personal interest',
    ),
    QuestionEntity(
      id: 'available_hours',
      text: 'How many hours per day can you dedicate to studying?',
      type: QuestionType.singleChoice,
      choices: [
        'Less than 1 hour',
        '1–2 hours',
        '2–4 hours',
        '4+ hours',
      ],
    ),
    QuestionEntity(
      id: 'study_style',
      text: 'What learning methods work best for you?',
      subtitle: 'Select all that apply',
      type: QuestionType.multipleChoice,
      choices: [
        'Reading books & notes',
        'Watching video lectures',
        'Solving practice problems',
        'Flashcards & spaced repetition',
        'Group study sessions',
        'Teaching / explaining to others',
      ],
    ),
    QuestionEntity(
      id: 'challenge',
      text: 'What is your biggest study challenge?',
      type: QuestionType.singleChoice,
      choices: [
        'Staying focused',
        'Procrastination',
        'Understanding complex topics',
        'Managing time',
        'Retaining information',
      ],
    ),
    QuestionEntity(
      id: 'deadline',
      text: 'Do you have an exam or deadline coming up?',
      type: QuestionType.singleChoice,
      choices: [
        'No deadline',
        'Within 1 month',
        '1–3 months away',
        '3+ months away',
      ],
      isRequired: false,
    ),
  ];

  // ─── LEARNING ─────────────────────────────────────────────────────────────

  static const List<QuestionEntity> _learning = [
    QuestionEntity(
      id: 'skill',
      text: 'What skill do you want to learn?',
      type: QuestionType.text,
      hint: 'e.g., Guitar, Spanish, Python, Drawing, Public Speaking',
    ),
    QuestionEntity(
      id: 'current_level',
      text: 'What is your current level in this skill?',
      type: QuestionType.singleChoice,
      choices: [
        'Complete beginner',
        'Had some exposure',
        'Intermediate — know the basics',
      ],
    ),
    QuestionEntity(
      id: 'motivation',
      text: 'Why do you want to learn this skill?',
      type: QuestionType.singleChoice,
      choices: [
        'Career advancement',
        'Personal hobby & enjoyment',
        'Personal growth & challenge',
        'To teach or share with others',
        'Other',
      ],
    ),
    QuestionEntity(
      id: 'time_per_week',
      text: 'How many hours per week can you practice?',
      type: QuestionType.singleChoice,
      choices: [
        'Less than 2 hours',
        '2–5 hours',
        '5–10 hours',
        '10+ hours',
      ],
    ),
    QuestionEntity(
      id: 'preferred_method',
      text: 'How do you prefer to learn?',
      subtitle: 'Select all that apply',
      type: QuestionType.multipleChoice,
      choices: [
        'Online videos & courses',
        'Books & articles',
        'Hands-on practice projects',
        'Structured bootcamps',
        'Finding a mentor or tutor',
        'Community & peer learning',
      ],
    ),
    QuestionEntity(
      id: 'milestone',
      text: 'What would "success" look like for you in 3 months?',
      type: QuestionType.text,
      hint: 'e.g., Play 5 songs on guitar, speak basic Spanish sentences',
      isRequired: false,
    ),
  ];
}
