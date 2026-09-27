# Flutter Design System, Component Reuse & Clean Architecture Rules

## 1. Design System Tokens (`core/theme`)
* **Unified Shadows (`AppShadows`):** Centralize all shadows in `lib/core/theme/app_shadows.dart`. Never hardcode ad-hoc `BoxShadow` lists in feature widgets. Use presets such as `AppShadows.softCard`, `AppShadows.subtleCard`, `AppShadows.insetWell`, `AppShadows.bloom`, `AppShadows.badge`, etc.
* **Unified Corner Curvatures (`AppRadius`):** Centralize all border radius tokens in `lib/core/theme/app_radius.dart`. Never use arbitrary `BorderRadius.circular()` in widgets; use pre-instantiated tokens like `AppRadius.cardRadius`, `AppRadius.wellRadius`, `AppRadius.badgeRadius`, `AppRadius.smRadius`, `AppRadius.mdRadius`, `AppRadius.dialogRadius`.

## 2. Component Reuse Guardrail (`core/components`)
* **Check First:** Always inspect `lib/core/components` before creating or designing any new UI component.
* **Promote Generic Components:** If a new component is generic or reusable across multiple features or screens (e.g., `AnimatedSettingTile`, `SectionTitle`, `SoftCard`, `AppConfirmationDialog`), it MUST be placed directly in `lib/core/components/` and re-exported from the feature folder for clean backward compatibility.

## 3. Clean Architecture Invariants
* **Strict Layer Separation:** Presentation controllers must strictly communicate through Domain Use Cases and Entities. Never inject, import, or call Data Sources or raw Storage services directly in Controllers.
* **Modular Widget Classes:** Avoid top-level builder functions returning `Widget` (`buildXSection`); create dedicated `StatelessWidget` / `StatefulWidget` classes to optimize Flutter element reconciliation.
* **Extract Compound Widgets & Dialogs:** Decompose complex compound widgets and modal dialogs (e.g., `ThemeCard`, `AiApiKeyDialog`) into dedicated files in `presentation/widgets/`.
