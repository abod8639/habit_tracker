# Habit Tracker

A **beautiful**, **responsive**, and **intuitive** habit tracking app built with Flutter — designed to help you build positive daily routines with ease.

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

### Bring Your Own Gemini API Key (BYOK)
Full flexibility and control over your AI quota and capabilities.
- **Custom Key Configuration**: Switch seamlessly between the built-in default Gemini key and your personal API key in Settings.
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

---

##  Highlights

-  **Create & manage daily habits** with a smooth user experience  
-  **Track your progress** with simple checkmarks and visual feedback  
-  **View rich statistics** with animated and interactive charts  
-  **Weekly & monthly summaries** to visualize your growth over time  
-  **Multiple beautiful themes** with support for dark/light modes and custom color pickers  
-  **Animated UI transitions** and smooth interactions enhance the user experience  
-  **Local storage** powered by Hive for persistent, offline access  
-  **Fully responsive design** — works beautifully on phones, tablets, desktops, and web  

---

##  Screenshots

**Home Page**  
![Rate](assets/image/2.png)  

**Theme Selection**  
![Themes](assets/image/4.png)

**Rate Page**  
![Home](assets/image/5.png)
![Rate](assets/image/3.png)

---

##  Getting Started

### 1. Install Flutter  
Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install).


### 2. Clone the Repository
```bash
git clone https://github.com/abod8639/habit_tracker.git
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
- **Dart SDK** ^3.7.0
- **Hive** for fast local storage
- **Firebase** for backend (Auth, Cloud Firestore, Cloud Messaging, Analytics)
- **GetX** for state management & routing

### Key Packages
- [`google_generative_ai`](https://pub.dev/packages/google_generative_ai) — Google Gemini AI SDK for chat & smart scanning  
- [`fl_chart`](https://pub.dev/packages/fl_chart) — Responsive and animated charts  
- [`flutter_heatmap_calendar`](https://pub.dev/packages/flutter_heatmap_calendar) — Visual heatmap for habits  
- [`flutter_slidable`](https://pub.dev/packages/flutter_slidable) — Swipe-to-delete/edit functionality  
- [`url_launcher`](https://pub.dev/packages/url_launcher) — External links (e.g. Google AI Studio)  
- [`catppuccin_flutter`](https://pub.dev/packages/catppuccin_flutter) — Beautiful theme presets  
- `flutter_local_notifications`, `flutter_colorpicker`, `flutter_secure_storage`, `hive_flutter`, and more

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

