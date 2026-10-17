# Habit Tracker

A **beautiful**, **responsive**, and **intuitive** habit tracking app built with Flutter — designed to help you build positive daily routines with ease.

<!-- ![image](assets/icon/habit_tracker_app_icon.png) -->
<div align="center">
<a href="assets/icon/habit_tracker_app_icon.png"><img src="assets/icon/habit_tracker_app_icon.png" width="300" alt="Habit Management" /></a> 
</div>

<div align="center">

[![Download Android APK](https://img.shields.io/badge/Download_APK-Android-3DDC84?logo=android&logoColor=white)](https://github.com/abod8639/habit_tracker/raw/main/APK/app-release.apk)
[![Latest Release](https://img.shields.io/github/v/release/abod8639/habit_tracker?logo=github&color=blue)](https://github.com/abod8639/habit_tracker/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-State_Management-00599C?logo=dart&logoColor=white)](https://riverpod.dev)
[![SQLite & Drift](https://img.shields.io/badge/SQLite-Drift_Database-003B57?logo=sqlite&logoColor=white)](https://drift.simonbinder.eu)
[![Firebase](https://img.shields.io/badge/Firebase-Auth_%26_Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Google Gemini AI](https://img.shields.io/badge/Google_Gemini-AI_Coach-4285F4?logo=google&logoColor=white)](https://ai.google.dev)
[![GoRouter](https://img.shields.io/badge/GoRouter-Navigation-40C4FF?logo=flutter&logoColor=black)](https://pub.dev/packages/go_router)
[![FL Chart](https://img.shields.io/badge/FL_Chart-Analytics-673AB7?logo=flutter&logoColor=white)](https://pub.dev/packages/fl_chart)
[![Home Widget](https://img.shields.io/badge/Home_Widget-Android_Widgets-34A853?logo=android&logoColor=white)](https://pub.dev/packages/home_widget)

</div>

<!-- 
[![downloads](https://img.shields.io/pub/dm/particles_network)](https://pub.dev/packages/particles_network/score) -->
---

## Recent Updates & Features

### AI Habit Coach & Interactive Chat (Powered by Google Gemini)
Engage with an intelligent AI habit coach designed to keep you motivated and consistent.
- **Conversational Habit Coaching**: Ask questions, troubleshoot routine plateaus, and seek advice on habit formation.
- **Real-time Feedback**: Interactive chat UI featuring typing indicators, message bubbles, and smooth scrolling.
- **Context-Aware Assistance**: Get tailored recommendations aligned with your goals.

### Smart AI Plan Generator & Questionnaire
Build a personalized routine in seconds through guided questionnaire flows.
- **Category-Based Assessment**: Choose from diverse life pillars including Fitness, Productivity, Health, and Mindfulness.
- **Targeted Questionnaires**: Answer focused questions to determine your routine needs, availability, and experience level.
- **One-Click Plan Adoption**: Review AI-generated habit roadmaps and import selected habits directly into your tracker.

### Bring Your Own Gemini API Key (BYOK) & Supported Models
Full flexibility and control over your AI quota and capabilities.
- **Custom Key Configuration**: Switch seamlessly between the built-in default Gemini key and your personal API key in Settings.
- **Universal Key Acceptance**: Accepts any valid Gemini API key generated from [Google AI Studio](https://aistudio.google.com/app/apikey) with automatic sanitization (stripping accidental quotes, whitespace, and variable prefixes).
- **Supported Gemini Models (Automatic Priority Order — Optimized for Speed)**:
  - **`gemini-flash-lite-latest`** — Ultra low-latency, instantaneous response model (default).
  - **`gemini-3.5-flash-lite`** — High-speed Flash-Lite model with zero reasoning overhead and sub-second generation.
  - **`gemini-3-flash-preview`** — Reliable fallback model with high quota availability.
  - **`gemini-3.5-flash`** / **`gemini-3.8-flash`** — Multimodal models with enhanced reasoning and high throughput.
  - **`gemini-flash-latest`** — Automatic alias tracking Google's latest stable Flash releases.
  - *Dynamic Forward-Compatibility*: Automatically queries Google's `/v1beta/models` endpoint for your key and activates any newer Gemini model supporting `generateContent`.
- **Self-Healing Fallback Architecture**: If a specific model is deprecated or restricted on a user's Google Cloud project (e.g. legacy 2.5 or 2.0 models), the app seamlessly cascades to the next working model with zero disruption to the user experience.
- **Direct Google AI Studio Link**: Open Google AI Studio with one click via `url_launcher` to generate your free key.
- **Privacy & Masking**: Masked key display ensuring credentials remain protected on-screen.

### AI Smart Scanner
Automatically extract habits from physical notes, diet sheets, or invoices.
- **Categorization**: Groups tasks (e.g., Breakfast, Lunch, Workout) with clear prefixes.
- **Emoji Enrichment**: Automatically adds relevant emojis (e.g., 🍳 for eggs, 🏃 for running).
- **Invoice Recognition**: Detects bills and merges amount, payee, and date into clean actionable habits.
- **Smart Validation**: Interactive review dialog allows previewing and cherry-picking habits before adding them.

### Data Isolation & Multi-User Safety
- **Logout Cache Purge**: `ClearLocalHabitsUseCase` wipes local Hive caches and resets reactive state immediately upon logout to protect multi-user privacy on shared devices.
- **Habit Deletion Confirmation**: Added explicit confirmation dialogs to prevent accidental loss of habit streaks.
- **Auto-Recovery & Sync**: Hive self-healing against unexpected crashes combined with Firestore "Last Write Wins" cloud synchronization.

### Material 3 Polish & Reactive Visualizations
- **Material 3 Navigation Drawer**: Redesigned navigation adhering to Material 3 drawer guidelines.
- **Dynamic Heatmap Synchronization**: Unique reactive keys guarantee immediate visual updates across monthly summaries and calendar heatmaps.
- **Interactive Bar Charts & Stats**: Visualize completion trends, streak badges, and goal attainment rates with dynamic theming.

### 📱 Android Home Screen Widget (Powered by `home_widget`)
Track your progress and stay on top of your daily routines directly from your device's home screen.
- **Live Habit Heatmap**: Displays your real-time progress using an integrated, compact calendar heatmap.
- **Pending Habits at a Glance**: Shows only unfinished daily habits with tactile Neumorphic styling; completed habits automatically disappear upon completion.
- **Instant Synchronization**: Automatically re-renders and refreshes whenever habits are checked off, added, or edited in the app.
- **One-Tap App Launch**: Tap anywhere on the widget to open the app directly.

---

##  Highlights

-  **Create & manage daily habits** with a smooth user experience  
-  **Track your progress** with simple checkmarks and visual feedback  
-  **Home screen widget** to view pending daily habits and live heatmap progress directly from your phone's home screen  
-  **View rich statistics** with animated and interactive charts  
-  **Weekly & monthly summaries** to visualize your growth over time  
-  **Multiple beautiful themes** with support for dark/light modes and custom color pickers  
-  **Animated UI transitions** and smooth interactions enhance the user experience  
-  **Local storage** powered by Hive for persistent, offline access  
-  **Fully responsive design** — works beautifully on phones, tablets, desktops, and web  

---

## Screenshots and components

<div align="center">


|  |  |
| :---: | :---: |
| <a href="https://raw.githubusercontent.com/abod8639/media/main/habit_tracker/assets/image/Habit%20tracker4.png"><img src="https://raw.githubusercontent.com/abod8639/media/main/habit_tracker/assets/image/Habit%20tracker4.png" width="450" alt="Theme Customization" /></a> | <a href="https://raw.githubusercontent.com/abod8639/media/main/habit_tracker/assets/image/Habit%20tracker9.png"><img src="https://raw.githubusercontent.com/abod8639/media/main/habit_tracker/assets/image/Habit%20tracker9.png" width="450" alt="Statistics & Analytics" /></a> |

 <a href="https://raw.githubusercontent.com/abod8639/media/main/habit_tracker/assets/image/Habit%20tracker10.png"><img src="https://raw.githubusercontent.com/abod8639/media/main/habit_tracker/assets/image/Habit%20tracker10.png" width="800" alt="Detailed Monthly Progress" /></a> 

</div>

---

## Download & Direct Install (Android)

You can download and install the app directly on your Android device without building from source:

<p align="center">
  <a href="https://github.com/abod8639/habit_tracker/raw/main/APK/app-release.apk">
    <img src="https://img.shields.io/badge/Direct_Download-Android_APK-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" height="42" />
  </a>
</p>

### Quick Installation Steps:
1. Tap the **Download Android APK** button above (or download directly from [`APK/app-release.apk`](https://github.com/abod8639/habit_tracker/raw/main/APK/app-release.apk)).
2. Once the download completes, open `app-release.apk` on your Android device.
3. If prompted, grant permission to **"Install unknown apps"** in your device settings.
4. Tap **Install** and launch the app.

---

## Getting Started

### 1. Install Flutter  
Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install).


### 2. Clone the Repository
```bash
git clone https://github.com/abod8639/flutter_habit_tracker.git
cd habit_tracker
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

---

## Tech Stack

### Core
- **Flutter** 3.x
- **Dart SDK** ^3.11.0
- **SQLite & Drift** for high-performance relational local persistence
- **Firebase** for backend (Auth, Cloud Firestore, Cloud Messaging, Analytics)
- **Riverpod** for reactive state management
- **GoRouter** for declarative navigation & deep linking

### Key Packages
- [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) — Reactive caching and state management  
- [`drift`](https://pub.dev/packages/drift) & [`sqlite3_flutter_libs`](https://pub.dev/packages/sqlite3_flutter_libs) — Type-safe SQLite database and persistence  
- [`home_widget`](https://pub.dev/packages/home_widget) — Android Home Screen Widget for quick access and live progress tracking  
- [`google_generative_ai`](https://pub.dev/packages/google_generative_ai) — Google Gemini AI SDK for chat & smart scanning  
- [`fl_chart`](https://pub.dev/packages/fl_chart) — Responsive and animated charts  
- [`flutter_heatmap_calendar`](https://pub.dev/packages/flutter_heatmap_calendar) — Visual heatmap for habits  
- [`go_router`](https://pub.dev/packages/go_router) — Declarative routing solution  
- [`flutter_slidable`](https://pub.dev/packages/flutter_slidable) — Swipe-to-delete/edit functionality  
- [`url_launcher`](https://pub.dev/packages/url_launcher) — External links (e.g. Google AI Studio)  
- `flutter_local_notifications`, `flutter_dotenv`, `dartz`, and more

---

## 🛆 Dev Tools
- `build_runner` & `hive_generator` — Code generation
- `flutter_lints` — Linting for clean, maintainable code

---

##  Contributing

Pull requests are welcome! Please check out our [Contributing Guide](CONTRIBUTING.md) for full details on our Clean Architecture guidelines, GetX standards, and submission workflow.

1. Fork the repo  
2. Create your feature branch (`git checkout -b feature/YourFeature`)  
3. Commit your changes (`git commit -m "feat: add YourFeature"`)  
4. Push (`git push origin feature/YourFeature`)  
5. Open a Pull Request  

---

##  License

This project is licensed under the MIT License – see `LICENSE` for details.

---

##  Acknowledgments

- Thanks to the Flutter team for this powerful toolkit  
- Special thanks to everyone who contributes and supports the project

