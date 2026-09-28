import 'package:flutter/material.dart';

const Map<String, Map<String, Color>> themeColors = {
  // --- ثيمات GitHub (معدلة لتناسب النحت الناعم) ---
  'github_dark_green': {
    'primary': Color(0xFF3FB950),
    'secondary': Color.fromARGB(255, 19, 160, 179),
    'background': Color(0xFF1E2228), // رمادي داكن يتيح توليد ضوء وظل
    'surface': Color(0xFF1E2228),    // متطابق مع الخلفية
    'error': Color(0xFFE5534B),
    'onPrimary': Color(0xFF0D1117),
    'onSecondary': Color(0xFFE6EDF3),
  },

  'github': {
    'primary': Color(0xFF0969DA),
    'secondary': Color(0xFF54A0FF),
    'background': Color(0xFFE8EEF5), // رمادي مائل للأزرق الفاتح جداً بدلاً من الأبيض الصافي
    'surface': Color(0xFFE8EEF5),
    'error': Color(0xFFCF222E),
    'onPrimary': Color(0xFFFFFFFF),
    'onSecondary': Color(0xFF24292F),
  },

  'github_dark': {
    'primary': Color.fromARGB(255, 100, 172, 255),
    'secondary': Color.fromARGB(255, 11, 96, 222),
    'background': Color(0xFF1C2128),
    'surface': Color(0xFF1C2128),
    'error': Color(0xFFF85149),
    'onPrimary': Color(0xFF0D1117),
    'onSecondary': Color(0xFFE6EDF3),
  },

  // --- ثيمات باستيل ناعمة (Light Neumorphism) ---
  'sunset': {
    'primary': Color(0xFFE67332),
    'secondary': Color.fromARGB(255, 242, 113, 74),
    'background': Color(0xFFF3ECE6), // بيج/خوخي ناعم جداً
    'surface': Color(0xFFF3ECE6),
    'error': Color(0xFFD64545),
    'onPrimary': Color(0xFFFFFFFF),
    'onSecondary': Color(0xFF4A3E39),
  },

  'lavender': {
    'primary': Color(0xFF8B68C8),
    'secondary': Color(0xFFA589D8),
    'background': Color(0xFFECE7F4), // لافندر ضبابي ناعم
    'surface': Color(0xFFECE7F4),
    'error': Color(0xFFC7435E),
    'onPrimary': Color(0xFFFFFFFF),
    'onSecondary': Color(0xFF3F374A),
  },

  'mint': {
    'primary': Color(0xFF199A88),
    'secondary': Color.fromARGB(255, 77, 135, 182),
    'background': Color(0xFFE5ECE8), // نعناعي رمادي هادئ
    'surface': Color(0xFFE5ECE8),
    'error': Color(0xFFD64545),
    'onPrimary': Color(0xFFFFFFFF),
    'onSecondary': Color(0xFF2D4039),
  },

  // --- ثيمات Catppuccin معدلة لأسلوب Soft UI ---
  'catppuccin': {
    'primary': Color.fromARGB(255, 130, 178, 255),
    'secondary': Color.fromARGB(255, 196, 147, 255),
    'background': Color(0xFF232534), // Mocha الأساسي معدل للتجسيم
    'surface': Color(0xFF232534),
    'error': Color.fromARGB(255, 255, 128, 164),
    'onPrimary': Color(0xFF11111B),
    'onSecondary': Color(0xFFCDD6F4),
  },

  'catppuccin_latte': {
    'primary': Color(0xFF1E66F5),
    'secondary': Color(0xFF8839EF),
    'background': Color(0xFFE6E9EF), // ناعم ومثالي لظلال النيومورفيزم الفاتحة
    'surface': Color(0xFFE6E9EF),
    'error': Color(0xFFD20F39),
    'onPrimary': Color(0xFFFFFFFF),
    'onSecondary': Color(0xFF4C4F69),
  },

  'catppuccin_macchiato': {
    'primary': Color(0xFF8AADF4),
    'secondary': Color(0xFFC6A0F6),
    'background': Color(0xFF2B2E42),
    'surface': Color(0xFF2B2E42),
    'error': Color(0xFFED8796),
    'onPrimary': Color(0xFF181926),
    'onSecondary': Color(0xFFCAD3F5),
  },

  // --- الثيمات الداكنة المتخصصة (Dark Neumorphism) ---
  'dracula': {
    'primary': Color.fromARGB(255, 176, 120, 255),
    'secondary': Color.fromARGB(255, 255, 110, 192),
    'background': Color(0xFF282A36), // لون دراكولا الشهير ممتاز للظلال
    'surface': Color(0xFF282A36),
    'error': Color(0xFFFF5555),
    'onPrimary': Color(0xFF21222C),
    'onSecondary': Color(0xFFF8F8F2),
  },

  'hologram': {
    'primary': Color(0xFF38BDF8),
    'secondary': Color.fromARGB(255, 138, 14, 233),
    'background': Color(0xFF1A2234), // أزرق كحلي ناعم بدلاً من الأسود الداكن جداً
    'surface': Color(0xFF1A2234),
    'error': Color(0xFFFB7185),
    'onPrimary': Color(0xFF0F172A),
    'onSecondary': Color(0xFFE2E8F0),
  },

  'neon_circuit': {
    'primary': Color(0xFF00E599),
    'secondary': Color.fromARGB(255, 5, 106, 150),
    'background': Color(0xFF192329), // زيتي داكن يسمح بظهور الحواف المنحوتة
    'surface': Color(0xFF192329),
    'error': Color(0xFFF43F5E),
    'onPrimary': Color(0xFF0A1014),
    'onSecondary': Color(0xFFE0F2FE),
  },
};