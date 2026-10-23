import 'package:intl/intl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/question_entity.dart';

/// Static data source aligned with the Octalysis Gamification & Behavioral Design Framework.
/// Designed to transform user onboarding from a cold clinical questionnaire into an inspiring,
/// identity-building "Discovery & Onboarding" journey (Core Drives 1, 2, 3, and 4).
class QuestionsDataSource {
  QuestionsDataSource._();

  static bool get _isArabic => Intl.getCurrentLocale().startsWith('ar');

  static List<QuestionEntity> forCategory(PlanCategory category) {
    if (_isArabic) {
      switch (category) {
        case PlanCategory.nutrition:
          return List<QuestionEntity>.from(_nutritionAr);
        case PlanCategory.sports:
          return List<QuestionEntity>.from(_sportsAr);
        case PlanCategory.study:
          return List<QuestionEntity>.from(_studyAr);
        case PlanCategory.learning:
          return List<QuestionEntity>.from(_learningAr);
      }
    } else {
      switch (category) {
        case PlanCategory.nutrition:
          return List<QuestionEntity>.from(_nutritionEn);
        case PlanCategory.sports:
          return List<QuestionEntity>.from(_sportsEn);
        case PlanCategory.study:
          return List<QuestionEntity>.from(_studyEn);
        case PlanCategory.learning:
          return List<QuestionEntity>.from(_learningEn);
      }
    }
  }

  // ─── NUTRITION (ARABIC) ────────────────────────────────────────────────────
  static const List<QuestionEntity> _nutritionAr = [
    QuestionEntity(
      id: 'age',
      text: 'لنبدأ بضبط بوصلة جسدك.. كم عمرك الحالي؟',
      subtitle: 'يساعدنا ذلك في مواءمة خطتك مع معدل الطاقة والأيض الطبيعي لديك',
      type: QuestionType.number,
      hint: '25',
      unit: 'سنة',
      maxValue: 120,
    ),
    QuestionEntity(
      id: 'weight',
      text: 'ما هي نقطة انطلاقك الحالية من حيث الوزن؟',
      subtitle: 'الرقم الحالي هو مجرد نقطة بداية لرحلة تطورك، وليس حكماً عليك',
      type: QuestionType.number,
      hint: '75',
      unit: 'كجم',
      maxValue: 200,
    ),
    QuestionEntity(
      id: 'height',
      text: 'كم يبلغ طولك؟',
      type: QuestionType.number,
      hint: '175',
      unit: 'سم',
      maxValue: 220,
    ),
    QuestionEntity(
      id: 'goal',
      text: 'ما هو التحول الصحي الذي تطمح لبنائه في هويتك القادمة؟',
      subtitle: 'اختر الغاية الكبرى التي ستمنح عاداتك اليومية معنى حقيقياً',
      type: QuestionType.singleChoice,
      choices: [
        'التخلص من الوزن الزائد والوصول لخفة وحيوية أعلى',
        'بناء كتلة عضلية قوية وجسد متناسق',
        'الحفاظ على توازن وزني الحالي واستقرار صحتي',
        'مضاعفة طاقتي اليومية والتخلص من الخمول',
        'تبني أسلوب حياة غذائي نقي ومستدام طويل الأمد',
      ],
    ),
    QuestionEntity(
      id: 'activity_level',
      text: 'كيف يبدو إيقاع حركتك ونشاطك في يومك المعتاد؟',
      type: QuestionType.singleChoice,
      choices: [
        'هادئ — أغلب وقتي مكتبي أو قليل الحركة',
        'خفيف الحركة — أمشي على فترات بسيطة خلال اليوم',
        'متوسط النشاط — أمارس الرياضة 2–3 مرات أسبوعياً',
        'عالي الحيوية — أمارس التمارين بانتظام 5+ مرات أسبوعياً',
      ],
    ),
    QuestionEntity(
      id: 'dietary_restrictions',
      text: 'ما هي القواعد أو التفضيلات الخاصة بنظامك الغذائي؟',
      subtitle: 'صمّم مسارك بما يناسب قناعاتك وطبيعة جسدك (اختر كل ما ينطبق)',
      type: QuestionType.multipleChoice,
      choices: [
        'لا توجد قيود — أتناول مختلف الأطعمة المتوازنة',
        'نباتي (Vegetarian)',
        'نباتي صرف (Vegan)',
        'خالٍ من الغلوتين',
        'خالٍ من اللاكتوز',
        'طعام حلال فقط',
        'قليل الكربوهيدرات / كيتو',
      ],
    ),
    QuestionEntity(
      id: 'water_intake',
      text: 'كيف تقيم علاقتك الحالية بشرب الماء وترطيب جسدك يومياً؟',
      type: QuestionType.singleChoice,
      choices: [
        'بداية متواضعة (أقل من لتر واحد يومياً)',
        'ترطيب جيد (1–2 لتر يومياً)',
        'ترطيب ممتاز ومستمر (أكثر من 2 لتر يومياً)',
      ],
    ),
    QuestionEntity(
      id: 'meals_per_day',
      text: 'ما هو نمط توزيع الوجبات الأقرب لروتينك اليومي؟',
      subtitle: 'سنربط عاداتك الجديدة بمواعيد وجباتك الحالية لتسهيل الالتزام',
      type: QuestionType.singleChoice,
      choices: [
        '1–2 وجبات رئيسية (أو صيام متقطع)',
        '3 وجبات منتظمة ومتوازنة',
        '4–5 وجبات متوسطة موزعة',
        '6+ وجبات خفيفة على مدار اليوم',
      ],
    ),
  ];

  // ─── NUTRITION (ENGLISH) ───────────────────────────────────────────────────
  static const List<QuestionEntity> _nutritionEn = [
    QuestionEntity(
      id: 'age',
      text: 'Let’s calibrate your personal baseline—how old are you?',
      subtitle: 'Helps us align your habits with your natural energy and metabolism',
      type: QuestionType.number,
      hint: '25',
      unit: 'years',
      maxValue: 120,
    ),
    QuestionEntity(
      id: 'weight',
      text: 'What is your starting weight today?',
      subtitle: 'Think of this simply as your starting coordinates on the map',
      type: QuestionType.number,
      hint: '75',
      unit: 'kg',
      maxValue: 200,
    ),
    QuestionEntity(
      id: 'height',
      text: 'What is your height?',
      type: QuestionType.number,
      hint: '175',
      unit: 'cm',
      maxValue: 220,
    ),
    QuestionEntity(
      id: 'goal',
      text: 'What nutritional identity and transformation are you claiming?',
      subtitle: 'Choose the core mission that gives your daily habits meaning',
      type: QuestionType.singleChoice,
      choices: [
        'Shed excess weight & feel lighter and sharper',
        'Build lean muscle mass & physical strength',
        'Maintain my current weight & metabolic balance',
        'Unlock high, sustained daily energy & mental clarity',
        'Cultivate a clean, mindful lifelong eating identity',
      ],
    ),
    QuestionEntity(
      id: 'activity_level',
      text: 'What does your daily movement rhythm look like right now?',
      type: QuestionType.singleChoice,
      choices: [
        'Calm rhythm (desk-focused, minimal daily movement)',
        'Lightly active (casual walks & light daily motion)',
        'Moderately active (intentional workouts 2–3x/week)',
        'High-octane (consistent training 5+x/week)',
      ],
    ),
    QuestionEntity(
      id: 'dietary_restrictions',
      text: 'Do you follow any specific dietary rules or preferences?',
      subtitle: 'Customize your nutrition rules (select all that apply)',
      type: QuestionType.multipleChoice,
      choices: [
        'No restrictions — flexible balanced eater',
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
      text: 'Where does your daily hydration habit stand right now?',
      type: QuestionType.singleChoice,
      choices: [
        'Room to grow (less than 1 liter/day)',
        'Solid baseline (1–2 liters/day)',
        'Peak hydration (more than 2 liters/day)',
      ],
    ),
    QuestionEntity(
      id: 'meals_per_day',
      text: 'How many meals naturally fit your daily rhythm?',
      subtitle: 'We will anchor your new micro-habits to your existing meals',
      type: QuestionType.singleChoice,
      choices: [
        '1–2 focused meals (or intermittent fasting)',
        '3 classic structured meals',
        '4–5 balanced smaller meals',
        '6+ mini-meals throughout the day',
      ],
    ),
  ];

  // ─── SPORTS (ARABIC) ───────────────────────────────────────────────────────
  static const List<QuestionEntity> _sportsAr = [
    QuestionEntity(
      id: 'age',
      text: 'كم عمرك الحالي؟',
      subtitle: 'نصمم أحمال التدريب والاستشفاء بما يناسب مرحلتك العمرية',
      type: QuestionType.number,
      hint: '25',
      unit: 'سنة',
      maxValue: 120,
    ),
    QuestionEntity(
      id: 'fitness_level',
      text: 'في أي مرحلة تقف اليوم في رحلتك الرياضية؟',
      subtitle: 'كل بطل بدأ من الخطوة الأولى — اختر وصفك الأقرب حالياً',
      type: QuestionType.singleChoice,
      choices: [
        'مرحلة التأسيس — نادراً ما أمارس الرياضة حالياً وأبحث عن بداية سهلة',
        'مرحلة الانطلاق — أتحرك وأتمرن من 1 إلى 2 مرة أسبوعياً',
        'مرحلة الاستمرارية — أمارس التمارين بانتظام 3–4 مرات أسبوعياً',
        'مرحلة الإتقان والأداء — أتمرن بقوة 5+ مرات أسبوعياً',
      ],
    ),
    QuestionEntity(
      id: 'goal',
      text: 'ما هي القوة أو النتيجة الكبرى التي تريد تحقيقها بجسدك؟',
      type: QuestionType.singleChoice,
      choices: [
        'حرق الدهون وبناء جسد رشيق وخفيف الحركة',
        'بناء القوة والكتلة العضلية البارزة',
        'رفع كفاءة القلب والنَفَس والتحمل البدني',
        'استعادة مرونة المفاصل وانسيابية الحركة بدون تيبّس',
        'رفع الجاهزية البدنية لرياضة أو بطولة معينة',
        'تجديد النشاط اليومي والتخلص من التوتر والضغوط',
      ],
    ),
    QuestionEntity(
      id: 'available_days',
      text: 'كم يوماً في الأسبوع ترغب في تخصيصه للاستثمار في لياقتك؟',
      subtitle: 'الاستمرارية على القليل تغلب الانقطاع بعد الكثير',
      type: QuestionType.singleChoice,
      choices: [
        '1–2 أيام (بداية ذكية لبناء العادة بدون ضغط)',
        '3–4 أيام (التوازن المثالي بين الإنجاز والاستشفاء)',
        '5–6 أيام (التزام عالي لبناء زخم قوي)',
        'يومياً (حركة نشطة كل يوم كجزء من هويتي)',
      ],
    ),
    QuestionEntity(
      id: 'session_duration',
      text: 'ما هي المساحة الزمنية التي يمكنك منحها لنفسك في كل جلسة؟',
      type: QuestionType.singleChoice,
      choices: [
        '15–30 دقيقة (جرعات مركزة وسريعة عالية الأثر)',
        '30–45 دقيقة (حصة متوازنة ومثالية)',
        '45–60 دقيقة (تمرين كامل ومتكامل)',
        'أكثر من 60 دقيقة (مساحة مفتوحة للتدريب العميق)',
      ],
    ),
    QuestionEntity(
      id: 'equipment',
      text: 'ما هي ساحة التدريب والأدوات المتوفرة بين يديك؟',
      subtitle: 'اختر كل ما يمكنك الوصول إليه بسهولة',
      type: QuestionType.multipleChoice,
      choices: [
        'نادي رياضي متكامل (جيم)',
        'أوزان منزلية أو حبال مقاومة',
        'مساحات خارجية مفتوحة (حديقة، ممشى، مضمار)',
        'مسبح للسباحة',
        'وزن الجسم فقط (تمارين منزلية حرة بدون معدات)',
      ],
    ),
    QuestionEntity(
      id: 'limitations',
      text: 'هل هناك أي منطقة في جسدك تحتاج رعاية خاصة أو تعاني من إصابة؟',
      subtitle: 'سلامتك أولاً — سنستبعد أي حركة قد تسبب لك إجهاداً غير آمن',
      type: QuestionType.text,
      hint: 'مثال: ركبة حساسة، ألم أسفل الظهر، أو اكتب "لا يوجد"',
      isRequired: false,
    ),
  ];

  // ─── SPORTS (ENGLISH) ──────────────────────────────────────────────────────
  static const List<QuestionEntity> _sportsEn = [
    QuestionEntity(
      id: 'age',
      text: 'How old are you?',
      subtitle: 'Helps us calibrate training intensity and recovery windows',
      type: QuestionType.number,
      hint: '25',
      unit: 'years',
      maxValue: 120,
    ),
    QuestionEntity(
      id: 'fitness_level',
      text: 'What stage of your athletic journey are you currently in?',
      subtitle: 'Every master started at level 1—pick your honest starting line',
      type: QuestionType.singleChoice,
      choices: [
        'Foundation Stage — rarely exercise right now, ready for an easy start',
        'Ignition Stage — moving & exercising 1–2x/week',
        'Momentum Stage — consistently active 3–4x/week',
        'Mastery Stage — high-frequency training 5+x/week',
      ],
    ),
    QuestionEntity(
      id: 'goal',
      text: 'What physical superpower or transformation are you building toward?',
      type: QuestionType.singleChoice,
      choices: [
        'Torch fat & build a lean, agile physique',
        'Build raw strength & noticeable muscle mass',
        'Upgrade cardiovascular stamina & endurance',
        'Unlock pain-free mobility, posture & flexibility',
        'Peak conditioning for a specific sport',
        'Boost daily vitality, mood & stress resilience',
      ],
    ),
    QuestionEntity(
      id: 'available_days',
      text: 'How many days per week will you invest in your movement streak?',
      subtitle: 'Consistency always beats occasional intensity',
      type: QuestionType.singleChoice,
      choices: [
        '1–2 days (frictionless minimum viable routine)',
        '3–4 days (the sweet spot of growth & recovery)',
        '5–6 days (high-momentum athletic commitment)',
        'Every day (daily movement as part of who I am)',
      ],
    ),
    QuestionEntity(
      id: 'session_duration',
      text: 'How much time can you realistically protect for each session?',
      type: QuestionType.singleChoice,
      choices: [
        '15–30 minutes (short, punchy micro-workouts)',
        '30–45 minutes (focused, efficient sessions)',
        '45–60 minutes (complete full-spectrum training)',
        '60+ minutes (deep, unhurried training blocks)',
      ],
    ),
    QuestionEntity(
      id: 'equipment',
      text: 'What training arena and gear do you have in your arsenal?',
      subtitle: 'Select all that apply',
      type: QuestionType.multipleChoice,
      choices: [
        'Full commercial gym',
        'Home weights & resistance bands',
        'Outdoor spaces (parks, running tracks)',
        'Swimming pool',
        'Zero equipment (bodyweight mastery anywhere)',
      ],
    ),
    QuestionEntity(
      id: 'limitations',
      text: 'Are there any injuries or areas of your body we should protect?',
      subtitle: 'We will strictly design around any physical limitations',
      type: QuestionType.text,
      hint: 'e.g., knee sensitivity, lower back tightness, or type None',
      isRequired: false,
    ),
  ];

  // ─── STUDY (ARABIC) ────────────────────────────────────────────────────────
  static const List<QuestionEntity> _studyAr = [
    QuestionEntity(
      id: 'subject',
      text: 'ما هو العلم أو المجال الدراسي الذي تسعى لإتقانه حالياً؟',
      type: QuestionType.text,
      hint: 'مثال: الرياضيات، علوم الحاسب، الطب، التاريخ، اللغات',
    ),
    QuestionEntity(
      id: 'current_level',
      text: 'كيف تقيم قاعدتك المعرفية الحالية في هذا المجال؟',
      type: QuestionType.singleChoice,
      choices: [
        'صفحة بيضاء — أبدأ من الصفر تماماً',
        'معرفة تأسيسية — ملمّ بالمفاهيم الأولية',
        'مستوى متوسط — أمتلك قاعدة جيدة وأريد التعمق',
        'مستوى متقدم — أسعى للتميز والإتقان الكامل',
      ],
    ),
    QuestionEntity(
      id: 'goal',
      text: 'ما هو الإنجاز الأكاديمي أو المعرفي الذي سيجعلك فخوراً بنفسك؟',
      type: QuestionType.text,
      hint: 'مثال: التفوق في الاختبار القادم، الحصول على شهادة احترافية، بناء مشروع',
    ),
    QuestionEntity(
      id: 'available_hours',
      text: 'ما هي ميزانية التركيز اليومية التي يمكنك الالتزام بها واقعياً؟',
      subtitle: 'جلسة قصيرة بتركيز عميق خير من ساعات طويلة مشتتة',
      type: QuestionType.singleChoice,
      choices: [
        'أقل من ساعة (جلسات تركيز سريعة ومكثفة)',
        '1–2 ساعة (إيقاع يومي ممتاز ومستدام)',
        '2–4 ساعات (انغماس دراسي عميق)',
        '4+ ساعات (معسكر دراسي مكثف)',
      ],
    ),
    QuestionEntity(
      id: 'study_style',
      text: 'ما هي الأدوات والأساليب التي تجعل عقلك يستوعب بأفضل شكل؟',
      subtitle: 'اختر أسلحتك المفضلة في التعلم (كل ما ينطبق)',
      type: QuestionType.multipleChoice,
      choices: [
        'القراءة المركزة وتلخيص الأفكار بأسلوبك',
        'مشاهدة الشروحات المرئية والمحاضرات التفاعلية',
        'التطبيق العملي وحل المسائل والاختبارات السابقة',
        'البطاقات الذكية (Flashcards) والتكرار المتباعد',
        'النقاش والمذاكرة المشتركة مع الزملاء',
        'تطبيق تقنية فاينمان (شرح المعلومة وكأنك تدرّسها لغيرك)',
      ],
    ),
    QuestionEntity(
      id: 'challenge',
      text: 'ما هي العقبة الأكبر التي تسرق تركيزك أو تعطل تقدمك الدراسي؟',
      subtitle: 'تشخيص العائق هو نصف الحل لهندسة عادات تتغلب عليه',
      type: QuestionType.singleChoice,
      choices: [
        'تشتت الانتباه وصعوبة الدخول في التركيز العميق',
        'ثقل البداية والتسويف قبل فتح الكتاب',
        'صعوبة تفكيك واستيعاب المفاهيم المعقدة',
        'فوضى الوقت وتراكم المهام دون تنظيم',
        'نسيان المعلومات بسرعة بعد مذاكرتها',
      ],
    ),
    QuestionEntity(
      id: 'deadline',
      text: 'هل هناك خط نهاية أو موعد اختبار قريب تستعد له؟',
      type: QuestionType.singleChoice,
      choices: [
        'لا يوجد موعد ضاغط (رحلة تعلم مستمرة ومفتوحة)',
        'تحدٍ قريب جداً (خلال أقل من شهر)',
        'مدى متوسط (خلال 1–3 أشهر)',
        'تخطيط مبكر ومريح (أكثر من 3 أشهر)',
      ],
      isRequired: false,
    ),
  ];

  // ─── STUDY (ENGLISH) ───────────────────────────────────────────────────────
  static const List<QuestionEntity> _studyEn = [
    QuestionEntity(
      id: 'subject',
      text: 'What subject or academic field are you setting out to master?',
      type: QuestionType.text,
      hint: 'e.g., Mathematics, Computer Science, Medicine, History',
    ),
    QuestionEntity(
      id: 'current_level',
      text: 'Where does your knowledge base currently stand in this subject?',
      type: QuestionType.singleChoice,
      choices: [
        'Blank canvas — starting fresh from ground zero',
        'Foundational — familiar with the core basics',
        'Intermediate — solid grasp, ready to go deeper',
        'Advanced — aiming for top-tier mastery',
      ],
    ),
    QuestionEntity(
      id: 'goal',
      text: 'What academic victory or milestone will make you genuinely proud?',
      type: QuestionType.text,
      hint: 'e.g., Ace my upcoming finals, earn a certification, master the curriculum',
    ),
    QuestionEntity(
      id: 'available_hours',
      text: 'How much daily deep-focus time can you realistically protect?',
      subtitle: 'One focused hour beats four distracted ones',
      type: QuestionType.singleChoice,
      choices: [
        'Under 1 hour (high-impact micro-study sprints)',
        '1–2 hours (sustainable daily deep work)',
        '2–4 hours (serious academic immersion)',
        '4+ hours (intensive exam-prep mode)',
      ],
    ),
    QuestionEntity(
      id: 'study_style',
      text: 'Which learning modalities unlock your brain’s best retention?',
      subtitle: 'Choose your preferred learning tools (select all that apply)',
      type: QuestionType.multipleChoice,
      choices: [
        'Active reading & synthesizing notes in my own words',
        'Visual lectures & video breakdowns',
        'Hands-on problem solving & past exam drills',
        'Active recall flashcards & spaced repetition',
        'Collaborative group study & discussion',
        'The Feynman Technique (teaching concepts out loud)',
      ],
    ),
    QuestionEntity(
      id: 'challenge',
      text: 'What is the #1 friction point slowing down your study momentum?',
      subtitle: 'Naming the obstacle lets us engineer habits that bypass it',
      type: QuestionType.singleChoice,
      choices: [
        'Digital distractions & losing focus mid-session',
        'Starting friction & procrastination before opening the material',
        'Feeling overwhelmed by dense, complex concepts',
        'Time blindness & falling behind schedule',
        'Forgetting material quickly after studying it',
      ],
    ),
    QuestionEntity(
      id: 'deadline',
      text: 'Do you have an upcoming exam or target deadline on the horizon?',
      type: QuestionType.singleChoice,
      choices: [
        'No fixed deadline (self-paced mastery journey)',
        'High-urgency sprint (within 1 month)',
        'Mid-range target (1–3 months away)',
        'Long-range runway (3+ months away)',
      ],
      isRequired: false,
    ),
  ];

  // ─── LEARNING (ARABIC) ─────────────────────────────────────────────────────
  static const List<QuestionEntity> _learningAr = [
    QuestionEntity(
      id: 'skill',
      text: 'ما هي المهارة الجديدة التي تريد إضافتها إلى قدراتك الشخصية؟',
      type: QuestionType.text,
      hint: 'مثال: التحدث بالإسبانية، البرمجة بلغة بايثون، التصميم، الإلقاء، العزف',
    ),
    QuestionEntity(
      id: 'current_level',
      text: 'أين تقف اليوم في رحلة اكتساب هذه المهارة؟',
      type: QuestionType.singleChoice,
      choices: [
        'مكتشف جديد — لم يسبق لي تجربتها من قبل',
        'بداية أولية — جربتها قليلاً ولدي خلفية بسيطة',
        'ممارس أساسي — أتقن المبادئ الأولية وأريد الارتقاء بمستواي',
      ],
    ),
    QuestionEntity(
      id: 'motivation',
      text: 'ما هو المحرك الداخلي الذي يدفعك لاكتساب هذه المهارة الآن؟',
      subtitle: 'ربط العادة بغاية عميقة يضمن لك الاستمرار حين يقل الحماس المؤقت',
      type: QuestionType.singleChoice,
      choices: [
        'فتح آفاق مهنية وفرص وظيفية أقوى',
        'إشباع شغفي الشخصي والاستمتاع بوقتي بذكاء',
        'تحدي ذاتي وبناء ثقة أعلى بقدراتي على التعلم',
        'نقل المعرفة ومشاركة هذه المهارة مع من حولي',
        'غاية شخصية أخرى خاصة بي',
      ],
    ),
    QuestionEntity(
      id: 'time_per_week',
      text: 'كم ساعة أسبوعياً يمكنك استثمارها في الممارسة العملية؟',
      type: QuestionType.singleChoice,
      choices: [
        'أقل من ساعتين (خطوات يومية مصغرة بقاعدة الدقيقتين)',
        '2–5 ساعات (تقدم أسبوعي ثابت وملموس)',
        '5–10 ساعات (تسارع عالٍ في بناء المهارة)',
        '10+ ساعات (انغماس كامل واحترافي)',
      ],
    ),
    QuestionEntity(
      id: 'preferred_method',
      text: 'ما هي بيئة وأسلوب التعلم الذي يشعل حماسك أكثر؟',
      subtitle: 'اختر كل ما ينطبق لتصميم عادات ممتعة غير مملة',
      type: QuestionType.multipleChoice,
      choices: [
        'الدورات المرئية والدروس التفاعلية عبر الإنترنت',
        'القراءة المتعمقة في الكتب والمقالات المرجعية',
        'التعلم بالممارسة وبناء مشاريع وتجارب حقيقية مباشرة',
        'المعسكرات التدريبية والمسارات المكثفة المجدولة',
        'التدريب المباشر مع موجه أو خبير (Mentor)',
        'التعلم التشاركي وسط مجتمع يشاركني نفس الشغف',
      ],
    ),
    QuestionEntity(
      id: 'milestone',
      text: 'تخيّل نفسك بعد 90 يوماً من الالتزام.. ما هو الإنجاز الملموس الذي سيبرهن لك نجاحك؟',
      subtitle: 'تحديد صورة النجاح يجعل عقلك يرى الهدف بوضوح كل يوم',
      type: QuestionType.text,
      hint: 'مثال: إجراء محادثة كاملة لمدة 10 دقائق، إطلاق تطبيقي الأول، عزف مقطوعة كاملة',
      isRequired: false,
    ),
  ];

  // ─── LEARNING (ENGLISH) ────────────────────────────────────────────────────
  static const List<QuestionEntity> _learningEn = [
    QuestionEntity(
      id: 'skill',
      text: 'What new skill are you ready to unlock and add to your identity?',
      type: QuestionType.text,
      hint: 'e.g., Guitar, Spanish, Python, UI Design, Public Speaking',
    ),
    QuestionEntity(
      id: 'current_level',
      text: 'Where are you starting from with this skill today?',
      type: QuestionType.singleChoice,
      choices: [
        'Fresh explorer — brand new to this craft',
        'Early dabbler — had some initial exposure',
        'Rising practitioner — know the basics, ready for real fluency',
      ],
    ),
    QuestionEntity(
      id: 'motivation',
      text: 'What deeper purpose is fueling your desire to master this skill?',
      subtitle: 'Connecting habits to an Epic Meaning keeps you going when willpower dips',
      type: QuestionType.singleChoice,
      choices: [
        'Accelerate my career & unlock new professional doors',
        'Pure creative joy, passion & fulfilling flow states',
        'Prove to myself that I can master hard things',
        'Create value, teach, or inspire others around me',
        'Another personal mission close to my heart',
      ],
    ),
    QuestionEntity(
      id: 'time_per_week',
      text: 'How many hours per week will you invest in deliberate practice?',
      type: QuestionType.singleChoice,
      choices: [
        'Under 2 hours (micro-practice habits that never miss)',
        '2–5 hours (steady, compounding weekly mastery)',
        '5–10 hours (fast-track skill acquisition)',
        '10+ hours (deep immersion & rapid transformation)',
      ],
    ),
    QuestionEntity(
      id: 'preferred_method',
      text: 'How do you love to learn and experiment best?',
      subtitle: 'Select all that apply so we can keep your habits engaging',
      type: QuestionType.multipleChoice,
      choices: [
        'Bite-sized online video courses & tutorials',
        'Deep-dive books, guides & written breakdowns',
        'Learning by building real, hands-on projects immediately',
        'Structured bootcamps & clear milestone tracks',
        'Guided feedback from a mentor or coach',
        'Learning alongside an accountability community or peers',
      ],
    ),
    QuestionEntity(
      id: 'milestone',
      text: 'Fast-forward 90 days of consistent action—what tangible win will prove you succeeded?',
      subtitle: 'Defining your Win State makes every daily micro-habit feel rewarding',
      type: QuestionType.text,
      hint: 'e.g., Hold a 10-minute conversation in Spanish, ship my first app, play 5 songs',
      isRequired: false,
    ),
  ];
}