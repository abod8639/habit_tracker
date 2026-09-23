# Contributing to Habit Tracker

Thank you for considering contributing to **Habit Tracker**! Contributions are what make the open-source community such an amazing place to learn, inspire, and create.

Please take a moment to review this document to ensure a smooth collaboration process.

---

## Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
   - [Prerequisites](#prerequisites)
   - [Setup Local Environment](#setup-local-environment)
3. [Architecture & Design Principles](#architecture--design-principles)
   - [Clean Architecture Overview](#clean-architecture-overview)
   - [Feature Scaffolding](#feature-scaffolding)
4. [Coding Standards](#coding-standards)
   - [SOLID Principles](#solid-principles)
   - [State Management with GetX](#state-management-with-getx)
   - [Widget Optimization](#widget-optimization)
   - [Async Safety](#async-safety)
5. [Development & Testing Workflow](#development--testing-workflow)
   - [Code Generation](#code-generation)
   - [Static Analysis & Formatting](#static-analysis--formatting)
   - [Running Tests](#running-tests)
6. [Git & Pull Request Guidelines](#git--pull-request-guidelines)
   - [Branch Naming](#branch-naming)
   - [Commit Messages](#commit-messages)
   - [Pull Request Checklist](#pull-request-checklist)

---

## Code of Conduct

We are committed to providing a welcoming, inclusive, and harassment-free environment for everyone. Please be respectful, constructive, and considerate of fellow contributors.

---

## Getting Started

### Prerequisites
- **Flutter SDK**: `>=3.11.3` (Dart SDK `>=3.7.0`)
- **Git**
- Target platform tools (Android SDK / Xcode / Linux build dependencies as needed)

### Setup Local Environment

1. **Fork and Clone the Repository**:
   ```bash
   git clone https://github.com/<your-username>/habit_tracker.git
   cd habit_tracker
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**:
   Copy the example environment file or configure `.env` in the root directory:
   ```bash
   cp .env.example .env # or create .env if not present
   ```
   Ensure necessary API keys (such as Gemini API key for AI features) are properly configured.

4. **Verify Build**:
   ```bash
   flutter run
   ```

---

## Architecture & Design Principles

The project strictly follows **Clean Architecture** and **SOLID** principles, maintaining a clear separation between business logic and UI.

### Clean Architecture Overview

Features reside in `lib/features/<feature_name>/` and are split into three layers:

```
lib/features/<feature_name>/
├── domain/                      # Enterprise & business logic (pure Dart)
│   ├── entities/                # Core business entities (immutable, Equatable)
│   ├── repositories/            # Repository contracts (interfaces)
│   └── usecases/                # Single-purpose business use cases (Callables)
├── data/                        # Data retrieval & persistence
│   ├── models/                  # Data models (JSON/Hive serialization, extends Entities)
│   ├── datasources/             # Local (Hive) & Remote (Firebase/Firestore/APIs) data sources
│   └── repositories/            # Implementation of domain repository contracts
└── presentation/                # UI Layer
    ├── controllers/             # GetX controllers handling presentation logic
    ├── bindings/                # GetX dependency injection bindings
    ├── pages/                   # Main screens
    └── widgets/                 # Reusable, small UI components
```

### Feature Scaffolding

To create a new feature following our Clean Architecture layout, you can use the built-in generator:
```bash
bash scaffold_feature.sh
```
Follow the interactive prompt to scaffold the domain, data, and presentation folders.

---

## Coding Standards

### SOLID Principles
- **Single Responsibility (SRP)**: Each class, widget, usecase, and controller should have one reason to change.
- **Open/Closed (OCP)**: Write extensible code using abstractions rather than modifying established core logic.
- **Liskov Substitution (LSP)**: Derived classes (such as models) must substitute their base types (entities) cleanly.
- **Interface Segregation (ISP)**: Create small, focused interfaces rather than bloated contracts.
- **Dependency Inversion (DIP)**: High-level modules (usecases/controllers) must depend on abstractions (repository interfaces), not concrete data sources.

### State Management with GetX
- **Separation of Logic**: Keep all UI logic in `GetxController`s. Never put business or asynchronous storage logic directly in Widget classes.
- **Bindings**: Prefer route-based or module-based `Bindings` for dependency injection instead of scattered `Get.put()` calls.
- **Granular Reactivity**: Avoid wrapping entire screens in `Obx`. Wrap only the specific, smallest leaf widget that needs to rebuild when reactive variables (`Rx`) change.

### Widget Optimization
- **`const` Constructors**: Always mark widgets with `const` wherever feasible to prevent unnecessary rebuilds.
- **Efficient Lists**: Use lazy-loading widgets (`ListView.builder`, `SliverList`, `SliverReorderableList`) for dynamic or long lists.
- **Heavy Computations**: Run CPU-intensive calculations (such as complex chart aggregations or heatmap history parsing) using `compute()` in background isolates.

### Async Safety
- When working with `BuildContext` across asynchronous gaps, always verify `mounted`:
  ```dart
  await performAsyncOperation();
  if (!context.mounted) return;
  Navigator.of(context).pop();
  ```

---

## Development & Testing Workflow

### Code Generation
When updating Hive models or generators, run `build_runner`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Static Analysis & Formatting
We maintain zero tolerance for analyzer warnings. Run static analysis before committing:
```bash
# Analyze code
flutter analyze

# Format code
dart format .
```

### Running Tests
Ensure existing tests pass and write unit tests for new use cases and controllers:
```bash
flutter test
```

---

## Git & Pull Request Guidelines

### Branch Naming
Use descriptive branch names with appropriate prefixes:
- `feature/<feature-name>` (e.g., `feature/habit-reminder-notifications`)
- `fix/<issue-name>` (e.g., `fix/hive-box-sync-race`)
- `refactor/<module-name>` (e.g., `refactor/category-controller`)
- `docs/<doc-name>` (e.g., `docs/update-contributing-guide`)

### Commit Messages
We follow the **Conventional Commits** specification:
- `feat: add AI habit categorization support`
- `fix: prevent sync collision on simultaneous updates`
- `refactor: extract heatmap computation to isolate`
- `test: add unit tests for get_habits_usecase`
- `docs: add CONTRIBUTING.md guidelines`

### Pull Request Checklist
Before submitting your PR, ensure:
1. [ ] Branch is rebased onto the latest `main`.
2. [ ] `flutter analyze` reports 0 issues.
3. [ ] `dart format .` has been run.
4. [ ] All tests pass via `flutter test`.
5. [ ] Any new feature includes clean separation (Domain, Data, Presentation).
6. [ ] Pull request description clearly explains the changes and references any related issue.
7. [ ] UI changes include before/after screenshots or short screen captures.

---

Thank you for helping build a better Habit Tracker! 🎯
