import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/config/app_config.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/core/utils/keyboard_shortcuts.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const String _githubRepoUrl =
      'https://github.com/abod8639/flutter_habit_tracker';
  static const String _downloadApkUrl =
      'https://github.com/abod8639/habit_tracker/raw/main/APK/app-release.apk';
  static const String _appVersion = AppConfig.appVersion;

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseSurface = theme.cardColor;
    final primaryColor = theme.primaryColor;
    final isArabic = Localizations.localeOf(
      context,
    ).languageCode.startsWith('ar');

    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: (KeyEvent event) => AppKeyboardShortcuts.handlePageKey(event),
      child: Scaffold(
        appBar: myAppBar(
          context: context,
          title: s.about,
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── APP HEADER & LOGO ─────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: baseSurface,
                            borderRadius: AppRadius.cardRadius,
                            boxShadow: AppShadows.softCard(isDark: isDark),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.8),
                              width: 1.2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: AppRadius.cardRadius,
                            child: Image.asset(
                              'assets/icon/icon for habit_tracker app.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 48,
                                    color: primaryColor,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Habit Tracker',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(
                              alpha: isDark ? 0.18 : 0.12,
                            ),
                            borderRadius: AppRadius.pillRadius,
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'v$_appVersion',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isArabic
                              ? 'تطبيق ذكي ومتطور لبناء العادات اليومية وتنظيم الروتين مدعوم بالذكاء الاصطناعي'
                              : 'A modern, intuitive habit tracking & productivity app built with Flutter & AI.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.65,
                            ),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── DEVELOPER CARD ───────────────────────────────────────────
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    baseSurface: baseSurface,
                    primaryColor: primaryColor,
                    title: isArabic ? 'المطور' : 'Developer',
                    icon: Icons.code_rounded,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: AppRadius.pillRadius,
                            child: CachedNetworkImage(
                              width: 90,
                              imageUrl:
                                  "https://avatars.githubusercontent.com/u/108903062?v=4",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dexter (abod8639)',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isArabic
                                      ? 'صُنع هذا التطبيق بكل حب واهتمام بواسطة Dexter'
                                      : 'This app was made with care and love by Dexter',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.65,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildTechChip(context, 'Flutter', isDark),
                          _buildTechChip(context, 'Clean Architecture', isDark),
                          _buildTechChip(context, 'Riverpod', isDark),
                          _buildTechChip(context, 'Drift / SQLite', isDark),
                          _buildTechChip(context, 'Firebase', isDark),
                          _buildTechChip(context, 'Google Gemini', isDark),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── TESTER CARD ──────────────────────────────────────────────
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    baseSurface: baseSurface,
                    primaryColor: primaryColor,
                    title: isArabic ? 'المختبِر' : 'Tester',
                    icon: Icons.verified_user_rounded,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: AppRadius.pillRadius,
                            child: CachedNetworkImage(
                              width: 90,
                              imageUrl:
                                  "https://styles.redditmedia.com/t5_ek4gzo/styles/profileIcon_0xqopel8y2sh1.jpeg?frame=1&auto=webp&crop=256%3A256%2Csmart&s=bacfd55489e45363009d86f33b46525d49ef87d0",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Yassin Omara',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isArabic
                                      ? 'تم اختبار هذا التطبيق بعناية فائقة بواسطة أفضل مختبِر في العالم'
                                      : 'This app was tested with great care by the best tester in the world',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.65,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildTechChip(context, 'Cybersecurity', isDark),
                          _buildTechChip(context, 'Ethical Hacking', isDark),
                          _buildTechChip(context, 'Testing', isDark),
                          _buildTechChip(context, 'Bug Bounty', isDark),
                          _buildTechChip(context, 'AI', isDark),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── KEY FEATURES ──────────────────────────────────────────────
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    baseSurface: baseSurface,
                    primaryColor: primaryColor,
                    title: isArabic ? 'أبرز المزايا' : 'Key Features',
                    icon: Icons.auto_awesome_rounded,
                    children: [
                      _buildFeatureTile(
                        context,
                        icon: Icons.psychology_rounded,
                        title: isArabic
                            ? 'مدرب العادات الذكي'
                            : 'AI Habit Coach',
                        subtitle: isArabic
                            ? 'محادثة ذكية واستشارات مستمرة لتحفيز العادات بواسطة Gemini'
                            : 'Conversational habit coaching powered by Google Gemini',
                        primaryColor: primaryColor,
                      ),
                      const Divider(height: 16),
                      _buildFeatureTile(
                        context,
                        icon: Icons.document_scanner_rounded,
                        title: isArabic
                            ? 'المسح الذكي للملاحظات'
                            : 'Smart Note Scanner',
                        subtitle: isArabic
                            ? 'استخراج العادات آلياً من الملاحظات والفواتير والخطط المكتوبة'
                            : 'Extract habits from physical notes, invoices, and routines',
                        primaryColor: primaryColor,
                      ),
                      const Divider(height: 16),
                      _buildFeatureTile(
                        context,
                        icon: Icons.calendar_month_rounded,
                        title: isArabic
                            ? 'خرائط الحرارة والإحصائيات'
                            : 'Heatmaps & Analytics',
                        subtitle: isArabic
                            ? 'متابعة بصرية دقيقة لمعدلات الالتزام والنمو اليومي والشهري'
                            : 'Interactive completion charts and monthly visual heatmaps',
                        primaryColor: primaryColor,
                      ),
                      const Divider(height: 16),
                      _buildFeatureTile(
                        context,
                        icon: Icons.widgets_rounded,
                        title: isArabic
                            ? 'ويدجت الشاشة الرئيسية'
                            : 'Home Screen Widget',
                        subtitle: isArabic
                            ? 'عرض العادات المتبقية وخريطة التقدم مباشرة من شاشة هاتفك'
                            : 'Compact Android widget displaying pending daily habits & heatmap',
                        primaryColor: primaryColor,
                      ),
                      const Divider(height: 16),
                      _buildFeatureTile(
                        context,
                        icon: Icons.cloud_sync_rounded,
                        title: isArabic
                            ? 'المزامنة السحابية والأمان'
                            : 'Cloud Sync & Privacy',
                        subtitle: isArabic
                            ? 'تخزين محلي فائق السرعة عبر SQLite ومزامنة موثوقة مع Cloud Firestore'
                            : 'Fast local SQLite persistence with Firestore multi-device sync',
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── LINKS & OPEN SOURCE ───────────────────────────────────────
                  _buildSectionCard(
                    context: context,
                    isDark: isDark,
                    baseSurface: baseSurface,
                    primaryColor: primaryColor,
                    title: isArabic
                        ? 'الروابط والمستودع'
                        : 'Links & Repository',
                    icon: Icons.link_rounded,
                    children: [
                      _buildActionTile(
                        context,
                        icon: Icons.code_rounded,
                        title: isArabic
                            ? 'المستودع البرمجي على GitHub'
                            : 'GitHub Repository',
                        subtitle: 'github.com/abod8639/flutter_habit_tracker',
                        onTap: () => _openUrl(_githubRepoUrl),
                        primaryColor: primaryColor,
                      ),
                      const Divider(height: 16),
                      _buildActionTile(
                        context,
                        icon: Icons.android_rounded,
                        title: isArabic
                            ? 'تحميل تطبيق Android APK'
                            : 'Download Android APK',
                        subtitle: isArabic
                            ? 'أحدث إصدار مباشر'
                            : 'Latest direct release',
                        onTap: () => _openUrl(_downloadApkUrl),
                        primaryColor: primaryColor,
                      ),
                      const Divider(height: 16),
                      _buildActionTile(
                        context,
                        icon: Icons.verified_user_rounded,
                        title: isArabic ? 'الترخيص' : 'License',
                        subtitle: 'MIT License (Open Source)',
                        onTap: () =>
                            _openUrl('$_githubRepoUrl/blob/main/LICENSE'),
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── FOOTER ────────────────────────────────────────────────────
                  Center(
                    child: Text(
                      'Habit Tracker • Built with Flutter and Dart\n© 2026 Dexter',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                        height: 1.5,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required bool isDark,
    required Color baseSurface,
    required Color primaryColor,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseSurface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.softCard(isDark: isDark),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Icon(icon, color: primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTechChip(BuildContext context, String label, bool isDark) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          primaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
          theme.cardColor,
        ),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.14),
          width: 0.9,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: AppRadius.mdRadius,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
