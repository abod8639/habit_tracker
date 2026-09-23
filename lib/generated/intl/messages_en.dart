// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "Add ${count} Habit(s) to Tracker";

  static String m1(days) => "${days} days ago";

  static String m2(count) =>
      "Are you sure you want to delete ${count} habit(s)? This action cannot be undone.";

  static String m3(message) => "Failed to clear data: ${message}";

  static String m4(count) => "${count} habits generated for you";

  static String m5(hours) => "${hours} hours ago";

  static String m6(count) => "${count} Selected";

  static String m7(minutes) => "${minutes} minutes ago";

  static String m8(count) => "${count} habits added to your tracker.";

  static String m9(time) => "Reminder set for ${time}";

  static String m10(streak) => "Day ${streak}";

  static String m11(category) => "Your ${category} Plan";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addFirstHabitSubtitle": MessageLookupByLibrary.simpleMessage(
            "Add your first habit with the + button"),
        "addHabitsToTracker": m0,
        "addNewHabit": MessageLookupByLibrary.simpleMessage("Add new Habit..."),
        "addedSelectedHabitsSuccess": MessageLookupByLibrary.simpleMessage(
            "Added the selected habits successfully."),
        "aiApiKeySubtitle": MessageLookupByLibrary.simpleMessage(
            "Custom Gemini API key for AI features"),
        "aiApiKeyTitle": MessageLookupByLibrary.simpleMessage("AI API Key"),
        "aiCoach": MessageLookupByLibrary.simpleMessage("AI Coach"),
        "aiGreeting": MessageLookupByLibrary.simpleMessage(
            "I\'m here to support you in your journey towards your goals."),
        "alreadyHaveAccount":
            MessageLookupByLibrary.simpleMessage("Already have an account?"),
        "answerRequired":
            MessageLookupByLibrary.simpleMessage("Answer required"),
        "apiKeyClearedSuccess": MessageLookupByLibrary.simpleMessage(
            "Custom API key removed. Using default key."),
        "apiKeyHint": MessageLookupByLibrary.simpleMessage(
            "Paste your Gemini API key (AIza...)"),
        "apiKeySavedSuccess":
            MessageLookupByLibrary.simpleMessage("API key saved successfully"),
        "appVersionAndInformation":
            MessageLookupByLibrary.simpleMessage("This app made by dexter "),
        "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
        "areYouSureYouWantToDeleteThisHabit":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to delete this habit?"),
        "authErrorDefault":
            MessageLookupByLibrary.simpleMessage("An error occurred"),
        "authErrorEmailInUse":
            MessageLookupByLibrary.simpleMessage("Email already in use"),
        "authErrorGoogle": MessageLookupByLibrary.simpleMessage(
            "An error occurred during Google sign-in"),
        "authErrorInvalidEmail":
            MessageLookupByLibrary.simpleMessage("Invalid email"),
        "authErrorNetworkFailed":
            MessageLookupByLibrary.simpleMessage("Network connection failed"),
        "authErrorSignOut": MessageLookupByLibrary.simpleMessage(
            "An error occurred during sign-out"),
        "authErrorTooManyRequests": MessageLookupByLibrary.simpleMessage(
            "Too many requests, please try again later"),
        "authErrorUserNotFound": MessageLookupByLibrary.simpleMessage(
            "No user found with this email"),
        "authErrorWeakPassword":
            MessageLookupByLibrary.simpleMessage("Password is too weak"),
        "authErrorWrongPassword":
            MessageLookupByLibrary.simpleMessage("Wrong password"),
        "backToLogin": MessageLookupByLibrary.simpleMessage("Back to Login"),
        "backupData": MessageLookupByLibrary.simpleMessage("Backup Data"),
        "barChartIsEmpty":
            MessageLookupByLibrary.simpleMessage("No habit data available"),
        "camera": MessageLookupByLibrary.simpleMessage("Camera"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "categoryLearning":
            MessageLookupByLibrary.simpleMessage("Learn a New Skill"),
        "categoryLearningDesc": MessageLookupByLibrary.simpleMessage(
            "Master any skill step by step"),
        "categoryNutrition": MessageLookupByLibrary.simpleMessage("Nutrition"),
        "categoryNutritionDesc": MessageLookupByLibrary.simpleMessage(
            "Improve your diet and reach your health goals"),
        "categorySports":
            MessageLookupByLibrary.simpleMessage("Sports & Fitness"),
        "categorySportsDesc": MessageLookupByLibrary.simpleMessage(
            "Build a consistent fitness routine"),
        "categoryStudy": MessageLookupByLibrary.simpleMessage("Study"),
        "categoryStudyDesc": MessageLookupByLibrary.simpleMessage(
            "Boost your academic performance"),
        "changeAppTheme":
            MessageLookupByLibrary.simpleMessage("Change app theme and color"),
        "chooseColor": MessageLookupByLibrary.simpleMessage("Choose Color"),
        "clear": MessageLookupByLibrary.simpleMessage("Clear"),
        "clearAllData": MessageLookupByLibrary.simpleMessage("Clear All Data"),
        "clearAllDataConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete all habits and settings? This action cannot be undone."),
        "clearChatConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to clear the conversation?"),
        "clearChatTitle": MessageLookupByLibrary.simpleMessage("Clear Chat"),
        "clearingData":
            MessageLookupByLibrary.simpleMessage("Clearing data..."),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "cloudSync": MessageLookupByLibrary.simpleMessage("Cloud Sync"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
        "completed": MessageLookupByLibrary.simpleMessage("Completed"),
        "completedLabel": MessageLookupByLibrary.simpleMessage("Completed"),
        "completionRate":
            MessageLookupByLibrary.simpleMessage("Completion Rate"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirm Password"),
        "confirmPasswordRequired": MessageLookupByLibrary.simpleMessage(
            "Please confirm your password"),
        "continueButton": MessageLookupByLibrary.simpleMessage("Continue"),
        "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
        "currentlySelected":
            MessageLookupByLibrary.simpleMessage("Currently Selected"),
        "customApiKeyActive":
            MessageLookupByLibrary.simpleMessage("Custom key active"),
        "customApiKeyDialogDesc": MessageLookupByLibrary.simpleMessage(
            "You can provide your own Gemini API key to use for AI features instead of the default key."),
        "customApiKeyDialogTitle":
            MessageLookupByLibrary.simpleMessage("Gemini API Key"),
        "dailyReminder": MessageLookupByLibrary.simpleMessage("Daily Reminder"),
        "dataClearedSuccess": MessageLookupByLibrary.simpleMessage(
            "Data cleared successfully! Restarting app..."),
        "daysAgo": m1,
        "defaultApiKeyActive":
            MessageLookupByLibrary.simpleMessage("Default system key active"),
        "defaultHabits1": MessageLookupByLibrary.simpleMessage("Click here"),
        "defaultHabits2":
            MessageLookupByLibrary.simpleMessage("<== Swipe left to edit"),
        "defaultHabits3":
            MessageLookupByLibrary.simpleMessage("Swipe right to delete ==>"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAllHabitsAndSettings": MessageLookupByLibrary.simpleMessage(
            "Delete all habits and settings"),
        "deleteHabit": MessageLookupByLibrary.simpleMessage("Delete Habit"),
        "deleteSelected":
            MessageLookupByLibrary.simpleMessage("Delete Selected"),
        "deleteSelectedConfirm": m2,
        "detectedHabits":
            MessageLookupByLibrary.simpleMessage("Detected Habits"),
        "dontHaveAccount":
            MessageLookupByLibrary.simpleMessage("Don\'t have an account?"),
        "drawer": MessageLookupByLibrary.simpleMessage(""),
        "drawerReat": MessageLookupByLibrary.simpleMessage("Statistics"),
        "drawerSetting": MessageLookupByLibrary.simpleMessage("Setting"),
        "drawerTheme": MessageLookupByLibrary.simpleMessage("Theme Color"),
        "editThisHabit":
            MessageLookupByLibrary.simpleMessage("Edit This Habit"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "emailInvalid":
            MessageLookupByLibrary.simpleMessage("Please enter a valid email"),
        "emailRequired":
            MessageLookupByLibrary.simpleMessage("Please enter your email"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "exportYourHabitData":
            MessageLookupByLibrary.simpleMessage("Export your habit data"),
        "failedToClearData": m3,
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot Password?"),
        "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
        "geminiApiKeyError": MessageLookupByLibrary.simpleMessage(
            "Invalid Gemini API key configuration."),
        "geminiQuotaExceeded": MessageLookupByLibrary.simpleMessage(
            "API rate limit exceeded. Please try again in a moment."),
        "geminiServerError":
            MessageLookupByLibrary.simpleMessage("Gemini server error."),
        "generateMyPlan":
            MessageLookupByLibrary.simpleMessage("Generate My Plan ✨"),
        "generatePlan": MessageLookupByLibrary.simpleMessage("Generate a Plan"),
        "generatePlanSubtitle": MessageLookupByLibrary.simpleMessage(
            "Choose a category and we\'ll build a personalized habit plan just for you."),
        "generatePlanTitle": MessageLookupByLibrary.simpleMessage(
            "What do you want\nto work on?"),
        "getKeyInfo": MessageLookupByLibrary.simpleMessage(
            "Get a free API key from Google AI Studio"),
        "habitsGeneratedCount": m4,
        "hambitstate": MessageLookupByLibrary.simpleMessage("Habit State"),
        "hoursAgo": m5,
        "importPreviouslyExportedData": MessageLookupByLibrary.simpleMessage(
            "Import previously exported data"),
        "incomplete": MessageLookupByLibrary.simpleMessage("Incomplete"),
        "initialGreeting": MessageLookupByLibrary.simpleMessage(
            "Hello. Please introduce yourself briefly as my AI coach and comment on my habit progress today."),
        "invalidApiKeyFormat": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid API key"),
        "isEmpty":
            MessageLookupByLibrary.simpleMessage("No habits tracked yet"),
        "itemsSelected": m6,
        "joinUs": MessageLookupByLibrary.simpleMessage("Join Us"),
        "justAMoment": MessageLookupByLibrary.simpleMessage("Just a moment"),
        "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
        "lan": MessageLookupByLibrary.simpleMessage("Language"),
        "lastSync": MessageLookupByLibrary.simpleMessage("Last sync"),
        "loadingHabits":
            MessageLookupByLibrary.simpleMessage("Loading your habits..."),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginRequired":
            MessageLookupByLibrary.simpleMessage("Please login first"),
        "loginToAccount":
            MessageLookupByLibrary.simpleMessage("Login to Account"),
        "loginToEnableSync": MessageLookupByLibrary.simpleMessage(
            "Login to enable cloud sync and backup"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutConfirmMessage": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to logout?"),
        "logoutConfirmTitle": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutFromAccount":
            MessageLookupByLibrary.simpleMessage("Logout from your account"),
        "minutesAgo": m7,
        "monthly": MessageLookupByLibrary.simpleMessage("Monthly Progress"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "nameRequired":
            MessageLookupByLibrary.simpleMessage("Please enter your name"),
        "noHabitsDetected":
            MessageLookupByLibrary.simpleMessage("No Habits Detected"),
        "noHabitsDetectedDesc": MessageLookupByLibrary.simpleMessage(
            "We could not find any clear tasks or habits in this image. Please try another one."),
        "noHabitsYet": MessageLookupByLibrary.simpleMessage("No habits yet"),
        "notSyncedYet": MessageLookupByLibrary.simpleMessage("Not synced yet"),
        "notificationTestSent": MessageLookupByLibrary.simpleMessage(
            "Test notification sent! Check your notification bar."),
        "notificationTestTitle":
            MessageLookupByLibrary.simpleMessage("Notification Test"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "notificationsDisabled":
            MessageLookupByLibrary.simpleMessage("Notifications disabled"),
        "online": MessageLookupByLibrary.simpleMessage("Online"),
        "optional": MessageLookupByLibrary.simpleMessage("Optional"),
        "or": MessageLookupByLibrary.simpleMessage("OR"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordMismatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "passwordRequired":
            MessageLookupByLibrary.simpleMessage("Please enter your password"),
        "passwordTooShort": MessageLookupByLibrary.simpleMessage(
            "Password must be at least 6 characters"),
        "paste": MessageLookupByLibrary.simpleMessage("Paste"),
        "pending": MessageLookupByLibrary.simpleMessage("Pending"),
        "pieChartIsEmpty":
            MessageLookupByLibrary.simpleMessage("No habits to display"),
        "planActivatedDesc": m8,
        "planActivatedTitle":
            MessageLookupByLibrary.simpleMessage("🎉 Plan activated!"),
        "planGenerationFailed": MessageLookupByLibrary.simpleMessage(
            "Failed to generate plan. Please try again."),
        "pleaseAnswerToContinue": MessageLookupByLibrary.simpleMessage(
            "Please answer this question to continue."),
        "ratepagetitle":
            MessageLookupByLibrary.simpleMessage("Habit Statistics"),
        "reminderSetFor": m9,
        "remindersEnabledBody": MessageLookupByLibrary.simpleMessage(
            "You will receive daily habit checks."),
        "remindersEnabledTitle":
            MessageLookupByLibrary.simpleMessage("Reminders Enabled!"),
        "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
        "resetPasswordDescription": MessageLookupByLibrary.simpleMessage(
            "Enter your email and we\'ll send you a link to reset your password"),
        "resetPasswordSuccess": MessageLookupByLibrary.simpleMessage(
            "Password reset link sent to your email"),
        "resetPasswordTitle":
            MessageLookupByLibrary.simpleMessage("Reset Password"),
        "resetToDefault":
            MessageLookupByLibrary.simpleMessage("Reset to Default"),
        "restoreData": MessageLookupByLibrary.simpleMessage("Restore Data"),
        "restoreFeatureWillBeAvailableInFutureUpdates":
            MessageLookupByLibrary.simpleMessage(
                "Restore feature will be available in future updates"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveSelected": MessageLookupByLibrary.simpleMessage("Save Selected"),
        "scanHabitsDesc": MessageLookupByLibrary.simpleMessage(
            "Extract tasks from an image automatically."),
        "scanHabitsTitle": MessageLookupByLibrary.simpleMessage("Scan Habits"),
        "scanImage": MessageLookupByLibrary.simpleMessage("Scan Image"),
        "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
        "selectAtLeastOneHabit":
            MessageLookupByLibrary.simpleMessage("Select at least one habit"),
        "sendResetLink":
            MessageLookupByLibrary.simpleMessage("Send Reset Link"),
        "setDailyReminder": MessageLookupByLibrary.simpleMessage(
            "Set a daily reminder for your habits"),
        "settingPageTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "signInWithGoogle":
            MessageLookupByLibrary.simpleMessage("Sign in with Google"),
        "signUpWithGoogle":
            MessageLookupByLibrary.simpleMessage("Sign up with Google"),
        "signup": MessageLookupByLibrary.simpleMessage("Sign Up"),
        "skipNow": MessageLookupByLibrary.simpleMessage("Skip Now"),
        "somethingWentWrong":
            MessageLookupByLibrary.simpleMessage("Something went wrong"),
        "streak": MessageLookupByLibrary.simpleMessage("Streak"),
        "streakDay": m10,
        "success": MessageLookupByLibrary.simpleMessage("Habit Success"),
        "summary": MessageLookupByLibrary.simpleMessage("Habit Summary"),
        "syncError": MessageLookupByLibrary.simpleMessage("Sync failed"),
        "syncFailed": MessageLookupByLibrary.simpleMessage("Sync failed"),
        "syncNow": MessageLookupByLibrary.simpleMessage("Sync Now"),
        "syncSuccess": MessageLookupByLibrary.simpleMessage("Sync successful"),
        "syncing": MessageLookupByLibrary.simpleMessage("Syncing..."),
        "systemLanguage":
            MessageLookupByLibrary.simpleMessage("System Language"),
        "tapToApply": MessageLookupByLibrary.simpleMessage("Tap to apply"),
        "tapToEdit": MessageLookupByLibrary.simpleMessage("Tap to configure"),
        "testNotification":
            MessageLookupByLibrary.simpleMessage("Test Notification"),
        "testNotificationDesc": MessageLookupByLibrary.simpleMessage(
            "Send a test notification to verify delivery"),
        "theFieldCantBeEmpty": MessageLookupByLibrary.simpleMessage(
            "The field can\'t be empty :)"),
        "themeNotFound":
            MessageLookupByLibrary.simpleMessage("Theme not found"),
        "themepage": MessageLookupByLibrary.simpleMessage("Custom Theme"),
        "themepagetitle": MessageLookupByLibrary.simpleMessage("Theme Setting"),
        "today": MessageLookupByLibrary.simpleMessage("Today Progress"),
        "tooltipItem": MessageLookupByLibrary.simpleMessage("Go do it now"),
        "tooltipItemCompleted":
            MessageLookupByLibrary.simpleMessage("Completed"),
        "total": MessageLookupByLibrary.simpleMessage("Total"),
        "trendChartIsEmpty": MessageLookupByLibrary.simpleMessage(
            "Not enough data to display trends"),
        "tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
        "typeMessage":
            MessageLookupByLibrary.simpleMessage("Type a message..."),
        "unexpectedError": MessageLookupByLibrary.simpleMessage(
            "An unexpected error occurred."),
        "user": MessageLookupByLibrary.simpleMessage("User"),
        "weekly": MessageLookupByLibrary.simpleMessage("weekly Progress"),
        "yourPlanTitle": m11
      };
}
