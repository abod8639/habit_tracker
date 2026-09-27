# Flutter Design System, Component Reuse & Clean Architecture Rules

## 1. Design System Tokens (`core/theme`)
* **Unified Shadows (`AppShadows`):** Centralize all shadows in `lib/core/theme/app_shadows.dart`. Never hardcode ad-hoc `BoxShadow` lists in feature widgets. Always use centralized presets such as `AppShadows.softCard`, `AppShadows.subtleCard`, `AppShadows.insetWell`, `AppShadows.wellDual`, `AppShadows.bloom`, `AppShadows.badge`, `AppShadows.buttonResting`, `AppShadows.buttonPressed`, `AppShadows.dotIndicator`, and `AppShadows.activeDot`.
* **Unified Corner Curvatures (`AppRadius`):** Centralize all border radius tokens in `lib/core/theme/app_radius.dart`. Never use arbitrary `BorderRadius.circular()` in widgets; use pre-instantiated tokens such as `AppRadius.cardRadius`, `AppRadius.wellRadius`, `AppRadius.badgeRadius`, `AppRadius.buttonRadius`, `AppRadius.smRadius`, `AppRadius.mdRadius`, `AppRadius.lgRadius`, and `AppRadius.dialogRadius`.

## 2. Component Reuse & Verification Guardrails (`core/components`)
* **Mandatory Pre-Creation Check:** Before writing or designing ANY new component, you MUST inspect `lib/core/components/` to verify whether an equivalent component already exists (e.g., `NeumorphicIconButton`, `SoftCard`, `SectionTitle`, `AppConfirmationDialog`).
* **Never Duplicate Existing Core Components:** Never introduce a feature-specific duplicate (e.g., do not build a custom circular button when `NeumorphicIconButton` exists).
* **Promote Generic Components Immediately:** If a component being built has no feature-specific domain dependencies and can be reused across different features or dialogs (e.g., `NeumorphicCardHeader`, `NeumorphicPillToggle`, `NeumorphicEmptyState`), it MUST be placed directly in `lib/core/components/` and imported where needed.

## 3. Clean Architecture Invariants
* **Strict Layer Separation:** Presentation controllers must strictly communicate through Domain Use Cases and Entities. Never inject, import, or call Data Sources or raw Storage services directly in Controllers.
* **Modular Widget Classes (No Helper Functions):** Never create top-level builder functions returning `Widget` (e.g., `buildSummaryCard()`, `buildChartsSection()`). Always declare dedicated `StatelessWidget` or `StatefulWidget` classes to enable `const` instantiation, optimize Flutter element reconciliation, and ensure clear widget tree inspector hierarchy.
* **Extract Compound Widgets & Dialogs:** Decompose complex compound widgets and modal dialogs (e.g., `ThemeCard`, `AiApiKeyDialog`) into dedicated files in `presentation/widgets/`.
