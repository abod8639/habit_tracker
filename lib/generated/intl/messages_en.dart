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

  static String m0(days) => "${days} days ago";

  static String m1(hours) => "${hours} hours ago";

  static String m2(minutes) => "${minutes} minutes ago";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "account": MessageLookupByLibrary.simpleMessage("Account"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addNewHabit": MessageLookupByLibrary.simpleMessage("Add new Habit..."),
        "aiApiKeySubtitle": MessageLookupByLibrary.simpleMessage(
            "Custom Gemini API key for AI features"),
        "aiApiKeyTitle": MessageLookupByLibrary.simpleMessage("AI API Key"),
        "aiCoach": MessageLookupByLibrary.simpleMessage("AI Coach"),
        "aiGreeting": MessageLookupByLibrary.simpleMessage(
            "I\'m here to support you in your journey towards your goals."),
        "alreadyHaveAccount":
            MessageLookupByLibrary.simpleMessage("Already have an account?"),
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
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "changeAppTheme":
            MessageLookupByLibrary.simpleMessage("Change app theme and color"),
        "clearAllData": MessageLookupByLibrary.simpleMessage("Clear All Data"),
        "clearChatConfirm": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to clear the conversation?"),
        "clearChatTitle": MessageLookupByLibrary.simpleMessage("Clear Chat"),
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
        "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
        "customApiKeyActive":
            MessageLookupByLibrary.simpleMessage("Custom key active"),
        "customApiKeyDialogDesc": MessageLookupByLibrary.simpleMessage(
            "You can provide your own Gemini API key to use for AI features instead of the default key."),
        "customApiKeyDialogTitle":
            MessageLookupByLibrary.simpleMessage("Gemini API Key"),
        "dailyReminder": MessageLookupByLibrary.simpleMessage("Daily Reminder"),
        "daysAgo": m0,
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
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot Password?"),
        "geminiApiKeyError": MessageLookupByLibrary.simpleMessage(
            "Invalid Gemini API key configuration."),
        "geminiQuotaExceeded": MessageLookupByLibrary.simpleMessage(
            "API rate limit exceeded. Please try again in a moment."),
        "geminiServerError":
            MessageLookupByLibrary.simpleMessage("Gemini server error."),
        "getKeyInfo": MessageLookupByLibrary.simpleMessage(
            "Get a free API key from Google AI Studio"),
        "hambitstate": MessageLookupByLibrary.simpleMessage("Habit State"),
        "hoursAgo": m1,
        "importPreviouslyExportedData": MessageLookupByLibrary.simpleMessage(
            "Import previously exported data"),
        "incomplete": MessageLookupByLibrary.simpleMessage("Incomplete"),
        "initialGreeting": MessageLookupByLibrary.simpleMessage(
            "Hello. Please introduce yourself briefly as my AI coach and comment on my habit progress today."),
        "invalidApiKeyFormat": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid API key"),
        "isEmpty":
            MessageLookupByLibrary.simpleMessage("No habits tracked yet"),
        "joinUs": MessageLookupByLibrary.simpleMessage("Join Us"),
        "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
        "lan": MessageLookupByLibrary.simpleMessage("Language"),
        "lastSync": MessageLookupByLibrary.simpleMessage("Last sync"),
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
        "minutesAgo": m2,
        "monthly": MessageLookupByLibrary.simpleMessage("Monthly Progress"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "nameRequired":
            MessageLookupByLibrary.simpleMessage("Please enter your name"),
        "notSyncedYet": MessageLookupByLibrary.simpleMessage("Not synced yet"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "online": MessageLookupByLibrary.simpleMessage("Online"),
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
        "ratepagetitle":
            MessageLookupByLibrary.simpleMessage("Habit Statistics"),
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
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "scanImage": MessageLookupByLibrary.simpleMessage("Scan Image"),
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
        "streak": MessageLookupByLibrary.simpleMessage("Streak"),
        "success": MessageLookupByLibrary.simpleMessage("Habit Success"),
        "summary": MessageLookupByLibrary.simpleMessage("Habit Summary"),
        "syncError": MessageLookupByLibrary.simpleMessage("Sync failed"),
        "syncFailed": MessageLookupByLibrary.simpleMessage("Sync failed"),
        "syncNow": MessageLookupByLibrary.simpleMessage("Sync Now"),
        "syncSuccess": MessageLookupByLibrary.simpleMessage("Sync successful"),
        "syncing": MessageLookupByLibrary.simpleMessage("Syncing..."),
        "tapToEdit": MessageLookupByLibrary.simpleMessage("Tap to configure"),
        "theFieldCantBeEmpty": MessageLookupByLibrary.simpleMessage(
            "The field can\'t be empty :)"),
        "themepage": MessageLookupByLibrary.simpleMessage("Custom Theme"),
        "themepagetitle": MessageLookupByLibrary.simpleMessage("Theme Setting"),
        "today": MessageLookupByLibrary.simpleMessage("Today Progress"),
        "tooltipItem": MessageLookupByLibrary.simpleMessage("Go do it now"),
        "tooltipItemCompleted":
            MessageLookupByLibrary.simpleMessage("Completed"),
        "total": MessageLookupByLibrary.simpleMessage("Total"),
        "trendChartIsEmpty": MessageLookupByLibrary.simpleMessage(
            "Not enough data to display trends"),
        "typeMessage":
            MessageLookupByLibrary.simpleMessage("Type a message..."),
        "unexpectedError": MessageLookupByLibrary.simpleMessage(
            "An unexpected error occurred."),
        "user": MessageLookupByLibrary.simpleMessage("User"),
        "weekly": MessageLookupByLibrary.simpleMessage("weekly Progress")
      };
}
