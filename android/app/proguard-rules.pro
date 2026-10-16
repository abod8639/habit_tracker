# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# SQLite3 & Drift
-keep class com.simonbinder.sqlite3_flutter_libs.** { *; }

# Home Widget
-keep class es.antonborri.home_widget.** { *; }

# Google Play Core (deferred components)
-dontwarn com.google.android.play.core.**
