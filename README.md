# Habit Tracker

A **beautiful**, **responsive**, and **intuitive** habit tracking app built with Flutter — designed to help you build positive daily routines with ease.

<!-- ![image](assets/icon/habit_tracker_app_icon.png) -->
<div align="center">
<a href="assets/icon/habit_tracker_app_icon.png"><img src="assets/icon/habit_tracker_app_icon.png" width="300" alt="Habit Management" /></a> 
</div>

<div align="center">

[![Download Android APK](https://img.shields.io/badge/Download_APK-Android-3DDC84?logo=android&logoColor=white)](https://github.com/abod8639/habit_tracker/raw/refs/heads/main/APK/app-release.apk)
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

<p align="center">
  <a href="https://github.com/abod8639/habit_tracker/raw/refs/heads/main/APK/app-release.apk">
    <img src="https://img.shields.io/badge/Direct_Download-Android_APK-3DDC84?logo=android&logoColor=white" alt="Download APK" height="42" />
  </a>
</p>

---

## Features & Architecture

### AI-Powered Productivity (Google Gemini)
- **AI Habit Coach**: Real-time conversational guidance and motivation powered by Gemini models.
- **Smart Plan Generator**: Tailored routine questionnaire flows to build and import habits in one click.
- **AI Document Scanner**: Extract structured habits directly from notes, receipts, and meal plans.
- **BYOK (Bring Your Own Key)**: Full support for custom Google AI Studio keys with automatic sanitization and model fallback.

### Performance & UI Excellence
- **Android Home Widget**: Live daily heatmap and pending habits glance powered by `home_widget`.
- **Interactive Analytics**: Monthly heatmaps and animated progress charts via `fl_chart`.
- **Neumorphic & Material 3 Design**: Refined tactile styling with dynamic theme color customization.
- **Multi-Device Responsive**: Optimized layouts across mobile, tablet, and desktop viewports.

### Reliability & Offline-First Persistence
- **Drift (SQLite) Engine**: High-performance local relational caching with reactive streams.
- **Cloud Synchronization**: Multi-device sync and backup via Firebase Authentication & Cloud Firestore.
- **Multi-User Security**: Clean session teardown and instant cache isolation upon sign-out.

---

## Screenshots and components

![alt text](https://raw.githubusercontent.com/abod8639/media/main/habit_tracker/assets/image/Section(3).png)
![alt text](https://raw.githubusercontent.com/abod8639/media/main/habit_tracker/assets/image/Section(5).png)

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
  <a href="https://github.com/abod8639/habit_tracker/raw/refs/heads/main/APK/app-release.apk">
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

#### State & Architecture
- [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) — Reactive caching, state management, and dependency injection
- [`dartz`](https://pub.dev/packages/dartz) — Functional programming (`Either`, `Option`) for failure handling
- [`equatable`](https://pub.dev/packages/equatable) — Value-based object equality for Clean Architecture entities
- [`go_router`](https://pub.dev/packages/go_router) — Declarative routing and deep linking solution

#### Database & Persistence
- [`drift`](https://pub.dev/packages/drift) & [`sqlite3_flutter_libs`](https://pub.dev/packages/sqlite3_flutter_libs) — Type-safe relational SQLite database & reactive streams
- [`path_provider`](https://pub.dev/packages/path_provider) & [`path`](https://pub.dev/packages/path) — File system path resolution and directory management

#### Cloud & Backend
- [`firebase_core`](https://pub.dev/packages/firebase_core) — Firebase integration backbone
- [`firebase_auth`](https://pub.dev/packages/firebase_auth) & [`google_sign_in`](https://pub.dev/packages/google_sign_in) — Secure authentication & Google Sign-In
- [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) — Cloud database synchronization & remote backups
- [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) — Push notifications via FCM
- [`firebase_analytics`](https://pub.dev/packages/firebase_analytics) — User behavior and crash telemetry

#### AI & Machine Learning
- [`google_generative_ai`](https://pub.dev/packages/google_generative_ai) — Official Google Gemini SDK for AI habit coaching & smart note scanning

#### UI, Visualization & Hardware
- [`fl_chart`](https://pub.dev/packages/fl_chart) — Highly customizable, animated performance & trend charts
- [`flutter_heatmap_calendar`](https://pub.dev/packages/flutter_heatmap_calendar) — GitHub-style visual habit heatmap calendar
- [`showcaseview`](https://pub.dev/packages/showcaseview) — Interactive onboarding & feature tours
- [`flutter_slidable`](https://pub.dev/packages/flutter_slidable) — Actionable swipe controls for habit tiles
- [`cached_network_image`](https://pub.dev/packages/cached_network_image) — Efficient image caching & placeholder handling
- [`home_widget`](https://pub.dev/packages/home_widget) — Android Home Screen Widget integration for live progress
- [`image_picker`](https://pub.dev/packages/image_picker) — Camera and gallery access for note scanning

#### Notifications & Utilities
- [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) — Scheduled alarms and daily reminder alerts
- [`timezone`](https://pub.dev/packages/timezone) & [`flutter_timezone`](https://pub.dev/packages/flutter_timezone) — Accurate timezone-aware notifications
- [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) — Secure environment variable management (`.env`)
- [`intl`](https://pub.dev/packages/intl) — Date formatting and multi-language localization (i18n)
- [`url_launcher`](https://pub.dev/packages/url_launcher) — In-app browser and external link dispatching
- [`http`](https://pub.dev/packages/http) — Composable HTTP networking

---

## Dev Tools
- `build_runner` & `drift_dev` — Type-safe SQLite code generation
- `icons_launcher` — Adaptive app icon generator
- `intl_utils` — Arb-based localization code generator
- `flutter_lints` — Lint rules for clean and maintainable code

---

## Contributing

Pull requests are welcome! Please ensure your contributions adhere to our Clean Architecture guidelines and Riverpod state management standards.

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

