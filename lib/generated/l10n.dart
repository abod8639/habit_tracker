// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// ``
  String get drawer {
    return Intl.message(
      '',
      name: 'drawer',
      desc: '',
      args: [],
    );
  }

  /// `Theme Color`
  String get drawerTheme {
    return Intl.message(
      'Theme Color',
      name: 'drawerTheme',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get drawerReat {
    return Intl.message(
      'Statistics',
      name: 'drawerReat',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get drawerSetting {
    return Intl.message(
      'Setting',
      name: 'drawerSetting',
      desc: '',
      args: [],
    );
  }

  /// `Theme Setting`
  String get themepagetitle {
    return Intl.message(
      'Theme Setting',
      name: 'themepagetitle',
      desc: '',
      args: [],
    );
  }

  /// `Custom Theme`
  String get themepage {
    return Intl.message(
      'Custom Theme',
      name: 'themepage',
      desc: '',
      args: [],
    );
  }

  /// `Habit Summary`
  String get summary {
    return Intl.message(
      'Habit Summary',
      name: 'summary',
      desc: '',
      args: [],
    );
  }

  /// `Habit Statistics`
  String get ratepagetitle {
    return Intl.message(
      'Habit Statistics',
      name: 'ratepagetitle',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message(
      'Total',
      name: 'total',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `Habit Success`
  String get success {
    return Intl.message(
      'Habit Success',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `Today Progress`
  String get today {
    return Intl.message(
      'Today Progress',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Progress`
  String get monthly {
    return Intl.message(
      'Monthly Progress',
      name: 'monthly',
      desc: '',
      args: [],
    );
  }

  /// `weekly Progress`
  String get weekly {
    return Intl.message(
      'weekly Progress',
      name: 'weekly',
      desc: '',
      args: [],
    );
  }

  /// `Habit State`
  String get hambitstate {
    return Intl.message(
      'Habit State',
      name: 'hambitstate',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `No habits tracked yet`
  String get isEmpty {
    return Intl.message(
      'No habits tracked yet',
      name: 'isEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No habit data available`
  String get barChartIsEmpty {
    return Intl.message(
      'No habit data available',
      name: 'barChartIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `No habits to display`
  String get pieChartIsEmpty {
    return Intl.message(
      'No habits to display',
      name: 'pieChartIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Not enough data to display trends`
  String get trendChartIsEmpty {
    return Intl.message(
      'Not enough data to display trends',
      name: 'trendChartIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completedLabel {
    return Intl.message(
      'Completed',
      name: 'completedLabel',
      desc: '',
      args: [],
    );
  }

  /// `Incomplete`
  String get incomplete {
    return Intl.message(
      'Incomplete',
      name: 'incomplete',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get tooltipItemCompleted {
    return Intl.message(
      'Completed',
      name: 'tooltipItemCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Go do it now`
  String get tooltipItem {
    return Intl.message(
      'Go do it now',
      name: 'tooltipItem',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingPageTitle {
    return Intl.message(
      'Settings',
      name: 'settingPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `Change app theme and color`
  String get changeAppTheme {
    return Intl.message(
      'Change app theme and color',
      name: 'changeAppTheme',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Daily Reminder`
  String get dailyReminder {
    return Intl.message(
      'Daily Reminder',
      name: 'dailyReminder',
      desc: '',
      args: [],
    );
  }

  /// `Set a daily reminder for your habits`
  String get setDailyReminder {
    return Intl.message(
      'Set a daily reminder for your habits',
      name: 'setDailyReminder',
      desc: '',
      args: [],
    );
  }

  /// `Backup Data`
  String get backupData {
    return Intl.message(
      'Backup Data',
      name: 'backupData',
      desc: '',
      args: [],
    );
  }

  /// `Export your habit data`
  String get exportYourHabitData {
    return Intl.message(
      'Export your habit data',
      name: 'exportYourHabitData',
      desc: '',
      args: [],
    );
  }

  /// `Restore Data`
  String get restoreData {
    return Intl.message(
      'Restore Data',
      name: 'restoreData',
      desc: '',
      args: [],
    );
  }

  /// `Import previously exported data`
  String get importPreviouslyExportedData {
    return Intl.message(
      'Import previously exported data',
      name: 'importPreviouslyExportedData',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get lan {
    return Intl.message(
      'Language',
      name: 'lan',
      desc: '',
      args: [],
    );
  }

  /// `Scan Image`
  String get scanImage {
    return Intl.message(
      'Scan Image',
      name: 'scanImage',
      desc: '',
      args: [],
    );
  }

  /// `Clear All Data`
  String get clearAllData {
    return Intl.message(
      'Clear All Data',
      name: 'clearAllData',
      desc: '',
      args: [],
    );
  }

  /// `Delete all habits and settings`
  String get deleteAllHabitsAndSettings {
    return Intl.message(
      'Delete all habits and settings',
      name: 'deleteAllHabitsAndSettings',
      desc: '',
      args: [],
    );
  }

  /// `Coming Soon`
  String get comingSoon {
    return Intl.message(
      'Coming Soon',
      name: 'comingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Restore feature will be available in future updates`
  String get restoreFeatureWillBeAvailableInFutureUpdates {
    return Intl.message(
      'Restore feature will be available in future updates',
      name: 'restoreFeatureWillBeAvailableInFutureUpdates',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `This app made by dexter `
  String get appVersionAndInformation {
    return Intl.message(
      'This app made by dexter ',
      name: 'appVersionAndInformation',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `The field can't be empty :)`
  String get theFieldCantBeEmpty {
    return Intl.message(
      'The field can\'t be empty :)',
      name: 'theFieldCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Add new Habit...`
  String get addNewHabit {
    return Intl.message(
      'Add new Habit...',
      name: 'addNewHabit',
      desc: '',
      args: [],
    );
  }

  /// `Edit This Habit`
  String get editThisHabit {
    return Intl.message(
      'Edit This Habit',
      name: 'editThisHabit',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Delete Habit`
  String get deleteHabit {
    return Intl.message(
      'Delete Habit',
      name: 'deleteHabit',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this habit?`
  String get areYouSureYouWantToDeleteThisHabit {
    return Intl.message(
      'Are you sure you want to delete this habit?',
      name: 'areYouSureYouWantToDeleteThisHabit',
      desc: '',
      args: [],
    );
  }

  /// `Click here`
  String get defaultHabits1 {
    return Intl.message(
      'Click here',
      name: 'defaultHabits1',
      desc: '',
      args: [],
    );
  }

  /// `<== Swipe left to edit`
  String get defaultHabits2 {
    return Intl.message(
      '<== Swipe left to edit',
      name: 'defaultHabits2',
      desc: '',
      args: [],
    );
  }

  /// `Swipe right to delete ==>`
  String get defaultHabits3 {
    return Intl.message(
      'Swipe right to delete ==>',
      name: 'defaultHabits3',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signup {
    return Intl.message(
      'Sign Up',
      name: 'signup',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Send Reset Link`
  String get sendResetLink {
    return Intl.message(
      'Send Reset Link',
      name: 'sendResetLink',
      desc: '',
      args: [],
    );
  }

  /// `Back to Login`
  String get backToLogin {
    return Intl.message(
      'Back to Login',
      name: 'backToLogin',
      desc: '',
      args: [],
    );
  }

  /// `OR`
  String get or {
    return Intl.message(
      'OR',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get signInWithGoogle {
    return Intl.message(
      'Sign in with Google',
      name: 'signInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Sign up with Google`
  String get signUpWithGoogle {
    return Intl.message(
      'Sign up with Google',
      name: 'signUpWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get dontHaveAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Skip Now`
  String get skipNow {
    return Intl.message(
      'Skip Now',
      name: 'skipNow',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Join Us`
  String get joinUs {
    return Intl.message(
      'Join Us',
      name: 'joinUs',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Login to Account`
  String get loginToAccount {
    return Intl.message(
      'Login to Account',
      name: 'loginToAccount',
      desc: '',
      args: [],
    );
  }

  /// `Login to enable cloud sync and backup`
  String get loginToEnableSync {
    return Intl.message(
      'Login to enable cloud sync and backup',
      name: 'loginToEnableSync',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Logout from your account`
  String get logoutFromAccount {
    return Intl.message(
      'Logout from your account',
      name: 'logoutFromAccount',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logoutConfirmTitle {
    return Intl.message(
      'Logout',
      name: 'logoutConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get logoutConfirmMessage {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'logoutConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get user {
    return Intl.message(
      'User',
      name: 'user',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email`
  String get emailRequired {
    return Intl.message(
      'Please enter your email',
      name: 'emailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get emailInvalid {
    return Intl.message(
      'Please enter a valid email',
      name: 'emailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get passwordRequired {
    return Intl.message(
      'Please enter your password',
      name: 'passwordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordTooShort {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordMismatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your name`
  String get nameRequired {
    return Intl.message(
      'Please enter your name',
      name: 'nameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your password`
  String get confirmPasswordRequired {
    return Intl.message(
      'Please confirm your password',
      name: 'confirmPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPasswordTitle {
    return Intl.message(
      'Reset Password',
      name: 'resetPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email and we'll send you a link to reset your password`
  String get resetPasswordDescription {
    return Intl.message(
      'Enter your email and we\'ll send you a link to reset your password',
      name: 'resetPasswordDescription',
      desc: '',
      args: [],
    );
  }

  /// `Password reset link sent to your email`
  String get resetPasswordSuccess {
    return Intl.message(
      'Password reset link sent to your email',
      name: 'resetPasswordSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No user found with this email`
  String get authErrorUserNotFound {
    return Intl.message(
      'No user found with this email',
      name: 'authErrorUserNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Wrong password`
  String get authErrorWrongPassword {
    return Intl.message(
      'Wrong password',
      name: 'authErrorWrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `Email already in use`
  String get authErrorEmailInUse {
    return Intl.message(
      'Email already in use',
      name: 'authErrorEmailInUse',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email`
  String get authErrorInvalidEmail {
    return Intl.message(
      'Invalid email',
      name: 'authErrorInvalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Password is too weak`
  String get authErrorWeakPassword {
    return Intl.message(
      'Password is too weak',
      name: 'authErrorWeakPassword',
      desc: '',
      args: [],
    );
  }

  /// `Too many requests, please try again later`
  String get authErrorTooManyRequests {
    return Intl.message(
      'Too many requests, please try again later',
      name: 'authErrorTooManyRequests',
      desc: '',
      args: [],
    );
  }

  /// `Network connection failed`
  String get authErrorNetworkFailed {
    return Intl.message(
      'Network connection failed',
      name: 'authErrorNetworkFailed',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get authErrorDefault {
    return Intl.message(
      'An error occurred',
      name: 'authErrorDefault',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred during Google sign-in`
  String get authErrorGoogle {
    return Intl.message(
      'An error occurred during Google sign-in',
      name: 'authErrorGoogle',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred during sign-out`
  String get authErrorSignOut {
    return Intl.message(
      'An error occurred during sign-out',
      name: 'authErrorSignOut',
      desc: '',
      args: [],
    );
  }

  /// `Cloud Sync`
  String get cloudSync {
    return Intl.message(
      'Cloud Sync',
      name: 'cloudSync',
      desc: '',
      args: [],
    );
  }

  /// `Sync Now`
  String get syncNow {
    return Intl.message(
      'Sync Now',
      name: 'syncNow',
      desc: '',
      args: [],
    );
  }

  /// `Syncing...`
  String get syncing {
    return Intl.message(
      'Syncing...',
      name: 'syncing',
      desc: '',
      args: [],
    );
  }

  /// `Sync successful`
  String get syncSuccess {
    return Intl.message(
      'Sync successful',
      name: 'syncSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Sync failed`
  String get syncError {
    return Intl.message(
      'Sync failed',
      name: 'syncError',
      desc: '',
      args: [],
    );
  }

  /// `Please login first`
  String get loginRequired {
    return Intl.message(
      'Please login first',
      name: 'loginRequired',
      desc: '',
      args: [],
    );
  }

  /// `Sync failed`
  String get syncFailed {
    return Intl.message(
      'Sync failed',
      name: 'syncFailed',
      desc: '',
      args: [],
    );
  }

  /// `Last sync`
  String get lastSync {
    return Intl.message(
      'Last sync',
      name: 'lastSync',
      desc: '',
      args: [],
    );
  }

  /// `Not synced yet`
  String get notSyncedYet {
    return Intl.message(
      'Not synced yet',
      name: 'notSyncedYet',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get justNow {
    return Intl.message(
      'Just now',
      name: 'justNow',
      desc: '',
      args: [],
    );
  }

  /// `{minutes} minutes ago`
  String minutesAgo(int minutes) {
    return Intl.message(
      '$minutes minutes ago',
      name: 'minutesAgo',
      desc: '',
      args: [minutes],
    );
  }

  /// `{hours} hours ago`
  String hoursAgo(int hours) {
    return Intl.message(
      '$hours hours ago',
      name: 'hoursAgo',
      desc: '',
      args: [hours],
    );
  }

  /// `{days} days ago`
  String daysAgo(int days) {
    return Intl.message(
      '$days days ago',
      name: 'daysAgo',
      desc: '',
      args: [days],
    );
  }

  /// `AI Coach`
  String get aiCoach {
    return Intl.message(
      'AI Coach',
      name: 'aiCoach',
      desc: '',
      args: [],
    );
  }

  /// `Type a message...`
  String get typeMessage {
    return Intl.message(
      'Type a message...',
      name: 'typeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get online {
    return Intl.message(
      'Online',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// `I'm here to support you in your journey towards your goals.`
  String get aiGreeting {
    return Intl.message(
      'I\'m here to support you in your journey towards your goals.',
      name: 'aiGreeting',
      desc: '',
      args: [],
    );
  }

  /// `Completion Rate`
  String get completionRate {
    return Intl.message(
      'Completion Rate',
      name: 'completionRate',
      desc: '',
      args: [],
    );
  }

  /// `Streak`
  String get streak {
    return Intl.message(
      'Streak',
      name: 'streak',
      desc: '',
      args: [],
    );
  }

  /// `Hello. Please introduce yourself briefly as my AI coach and comment on my habit progress today.`
  String get initialGreeting {
    return Intl.message(
      'Hello. Please introduce yourself briefly as my AI coach and comment on my habit progress today.',
      name: 'initialGreeting',
      desc: '',
      args: [],
    );
  }

  /// `Clear Chat`
  String get clearChatTitle {
    return Intl.message(
      'Clear Chat',
      name: 'clearChatTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear the conversation?`
  String get clearChatConfirm {
    return Intl.message(
      'Are you sure you want to clear the conversation?',
      name: 'clearChatConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `API rate limit exceeded. Please try again in a moment.`
  String get geminiQuotaExceeded {
    return Intl.message(
      'API rate limit exceeded. Please try again in a moment.',
      name: 'geminiQuotaExceeded',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Gemini API key configuration.`
  String get geminiApiKeyError {
    return Intl.message(
      'Invalid Gemini API key configuration.',
      name: 'geminiApiKeyError',
      desc: '',
      args: [],
    );
  }

  /// `Gemini server error.`
  String get geminiServerError {
    return Intl.message(
      'Gemini server error.',
      name: 'geminiServerError',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred.`
  String get unexpectedError {
    return Intl.message(
      'An unexpected error occurred.',
      name: 'unexpectedError',
      desc: '',
      args: [],
    );
  }

  /// `AI API Key`
  String get aiApiKeyTitle {
    return Intl.message(
      'AI API Key',
      name: 'aiApiKeyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Custom Gemini API key for AI features`
  String get aiApiKeySubtitle {
    return Intl.message(
      'Custom Gemini API key for AI features',
      name: 'aiApiKeySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Custom key active`
  String get customApiKeyActive {
    return Intl.message(
      'Custom key active',
      name: 'customApiKeyActive',
      desc: '',
      args: [],
    );
  }

  /// `Default system key active`
  String get defaultApiKeyActive {
    return Intl.message(
      'Default system key active',
      name: 'defaultApiKeyActive',
      desc: '',
      args: [],
    );
  }

  /// `Gemini API Key`
  String get customApiKeyDialogTitle {
    return Intl.message(
      'Gemini API Key',
      name: 'customApiKeyDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `You can provide your own Gemini API key to use for AI features instead of the default key.`
  String get customApiKeyDialogDesc {
    return Intl.message(
      'You can provide your own Gemini API key to use for AI features instead of the default key.',
      name: 'customApiKeyDialogDesc',
      desc: '',
      args: [],
    );
  }

  /// `Paste your Gemini API key (AIza...)`
  String get apiKeyHint {
    return Intl.message(
      'Paste your Gemini API key (AIza...)',
      name: 'apiKeyHint',
      desc: '',
      args: [],
    );
  }

  /// `Reset to Default`
  String get resetToDefault {
    return Intl.message(
      'Reset to Default',
      name: 'resetToDefault',
      desc: '',
      args: [],
    );
  }

  /// `API key saved successfully`
  String get apiKeySavedSuccess {
    return Intl.message(
      'API key saved successfully',
      name: 'apiKeySavedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Custom API key removed. Using default key.`
  String get apiKeyClearedSuccess {
    return Intl.message(
      'Custom API key removed. Using default key.',
      name: 'apiKeyClearedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid API key`
  String get invalidApiKeyFormat {
    return Intl.message(
      'Please enter a valid API key',
      name: 'invalidApiKeyFormat',
      desc: '',
      args: [],
    );
  }

  /// `Get a free API key from Google AI Studio`
  String get getKeyInfo {
    return Intl.message(
      'Get a free API key from Google AI Studio',
      name: 'getKeyInfo',
      desc: '',
      args: [],
    );
  }

  /// `Tap to configure`
  String get tapToEdit {
    return Intl.message(
      'Tap to configure',
      name: 'tapToEdit',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Paste`
  String get paste {
    return Intl.message(
      'Paste',
      name: 'paste',
      desc: '',
      args: [],
    );
  }

  /// `System Language`
  String get systemLanguage {
    return Intl.message(
      'System Language',
      name: 'systemLanguage',
      desc: '',
      args: [],
    );
  }

  /// `No habits yet`
  String get noHabitsYet {
    return Intl.message(
      'No habits yet',
      name: 'noHabitsYet',
      desc: '',
      args: [],
    );
  }

  /// `Add your first habit with the + button`
  String get addFirstHabitSubtitle {
    return Intl.message(
      'Add your first habit with the + button',
      name: 'addFirstHabitSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} Selected`
  String itemsSelected(int count) {
    return Intl.message(
      '$count Selected',
      name: 'itemsSelected',
      desc: '',
      args: [count],
    );
  }

  /// `Choose Color`
  String get chooseColor {
    return Intl.message(
      'Choose Color',
      name: 'chooseColor',
      desc: '',
      args: [],
    );
  }

  /// `Delete Selected`
  String get deleteSelected {
    return Intl.message(
      'Delete Selected',
      name: 'deleteSelected',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete {count} habit(s)? This action cannot be undone.`
  String deleteSelectedConfirm(int count) {
    return Intl.message(
      'Are you sure you want to delete $count habit(s)? This action cannot be undone.',
      name: 'deleteSelectedConfirm',
      desc: '',
      args: [count],
    );
  }

  /// `Scan Habits`
  String get scanHabitsTitle {
    return Intl.message(
      'Scan Habits',
      name: 'scanHabitsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Extract tasks from an image automatically.`
  String get scanHabitsDesc {
    return Intl.message(
      'Extract tasks from an image automatically.',
      name: 'scanHabitsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `No Habits Detected`
  String get noHabitsDetected {
    return Intl.message(
      'No Habits Detected',
      name: 'noHabitsDetected',
      desc: '',
      args: [],
    );
  }

  /// `We could not find any clear tasks or habits in this image. Please try another one.`
  String get noHabitsDetectedDesc {
    return Intl.message(
      'We could not find any clear tasks or habits in this image. Please try another one.',
      name: 'noHabitsDetectedDesc',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Detected Habits`
  String get detectedHabits {
    return Intl.message(
      'Detected Habits',
      name: 'detectedHabits',
      desc: '',
      args: [],
    );
  }

  /// `Save Selected`
  String get saveSelected {
    return Intl.message(
      'Save Selected',
      name: 'saveSelected',
      desc: '',
      args: [],
    );
  }

  /// `Added the selected habits successfully.`
  String get addedSelectedHabitsSuccess {
    return Intl.message(
      'Added the selected habits successfully.',
      name: 'addedSelectedHabitsSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message(
      'Try Again',
      name: 'tryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Loading your habits...`
  String get loadingHabits {
    return Intl.message(
      'Loading your habits...',
      name: 'loadingHabits',
      desc: '',
      args: [],
    );
  }

  /// `Just a moment`
  String get justAMoment {
    return Intl.message(
      'Just a moment',
      name: 'justAMoment',
      desc: '',
      args: [],
    );
  }

  /// `Clearing data...`
  String get clearingData {
    return Intl.message(
      'Clearing data...',
      name: 'clearingData',
      desc: '',
      args: [],
    );
  }

  /// `Data cleared successfully! Restarting app...`
  String get dataClearedSuccess {
    return Intl.message(
      'Data cleared successfully! Restarting app...',
      name: 'dataClearedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to clear data: {message}`
  String failedToClearData(String message) {
    return Intl.message(
      'Failed to clear data: $message',
      name: 'failedToClearData',
      desc: '',
      args: [message],
    );
  }

  /// `Are you sure you want to delete all habits and settings? This action cannot be undone.`
  String get clearAllDataConfirm {
    return Intl.message(
      'Are you sure you want to delete all habits and settings? This action cannot be undone.',
      name: 'clearAllDataConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Notifications disabled`
  String get notificationsDisabled {
    return Intl.message(
      'Notifications disabled',
      name: 'notificationsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Reminder set for {time}`
  String reminderSetFor(String time) {
    return Intl.message(
      'Reminder set for $time',
      name: 'reminderSetFor',
      desc: '',
      args: [time],
    );
  }

  /// `Test Notification`
  String get testNotification {
    return Intl.message(
      'Test Notification',
      name: 'testNotification',
      desc: '',
      args: [],
    );
  }

  /// `Send a test notification to verify delivery`
  String get testNotificationDesc {
    return Intl.message(
      'Send a test notification to verify delivery',
      name: 'testNotificationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Notification Test`
  String get notificationTestTitle {
    return Intl.message(
      'Notification Test',
      name: 'notificationTestTitle',
      desc: '',
      args: [],
    );
  }

  /// `Test notification sent! Check your notification bar.`
  String get notificationTestSent {
    return Intl.message(
      'Test notification sent! Check your notification bar.',
      name: 'notificationTestSent',
      desc: '',
      args: [],
    );
  }

  /// `Reminders Enabled!`
  String get remindersEnabledTitle {
    return Intl.message(
      'Reminders Enabled!',
      name: 'remindersEnabledTitle',
      desc: '',
      args: [],
    );
  }

  /// `You will receive daily habit checks.`
  String get remindersEnabledBody {
    return Intl.message(
      'You will receive daily habit checks.',
      name: 'remindersEnabledBody',
      desc: '',
      args: [],
    );
  }

  /// `Day {streak}`
  String streakDay(int streak) {
    return Intl.message(
      'Day $streak',
      name: 'streakDay',
      desc: '',
      args: [streak],
    );
  }

  /// `Currently Selected`
  String get currentlySelected {
    return Intl.message(
      'Currently Selected',
      name: 'currentlySelected',
      desc: '',
      args: [],
    );
  }

  /// `Tap to apply`
  String get tapToApply {
    return Intl.message(
      'Tap to apply',
      name: 'tapToApply',
      desc: '',
      args: [],
    );
  }

  /// `Theme not found`
  String get themeNotFound {
    return Intl.message(
      'Theme not found',
      name: 'themeNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Generate a Plan`
  String get generatePlan {
    return Intl.message(
      'Generate a Plan',
      name: 'generatePlan',
      desc: '',
      args: [],
    );
  }

  /// `What do you want\nto work on?`
  String get generatePlanTitle {
    return Intl.message(
      'What do you want\nto work on?',
      name: 'generatePlanTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose a category and we'll build a personalized habit plan just for you.`
  String get generatePlanSubtitle {
    return Intl.message(
      'Choose a category and we\'ll build a personalized habit plan just for you.',
      name: 'generatePlanSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Generate My Plan ✨`
  String get generateMyPlan {
    return Intl.message(
      'Generate My Plan ✨',
      name: 'generateMyPlan',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueButton {
    return Intl.message(
      'Continue',
      name: 'continueButton',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message(
      'Optional',
      name: 'optional',
      desc: '',
      args: [],
    );
  }

  /// `Your {category} Plan`
  String yourPlanTitle(String category) {
    return Intl.message(
      'Your $category Plan',
      name: 'yourPlanTitle',
      desc: '',
      args: [category],
    );
  }

  /// `{count} habits generated for you`
  String habitsGeneratedCount(int count) {
    return Intl.message(
      '$count habits generated for you',
      name: 'habitsGeneratedCount',
      desc: '',
      args: [count],
    );
  }

  /// `Select all`
  String get selectAll {
    return Intl.message(
      'Select all',
      name: 'selectAll',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  /// `Add {count} Habit(s) to Tracker`
  String addHabitsToTracker(int count) {
    return Intl.message(
      'Add $count Habit(s) to Tracker',
      name: 'addHabitsToTracker',
      desc: '',
      args: [count],
    );
  }

  /// `Select at least one habit`
  String get selectAtLeastOneHabit {
    return Intl.message(
      'Select at least one habit',
      name: 'selectAtLeastOneHabit',
      desc: '',
      args: [],
    );
  }

  /// `Answer required`
  String get answerRequired {
    return Intl.message(
      'Answer required',
      name: 'answerRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please answer this question to continue.`
  String get pleaseAnswerToContinue {
    return Intl.message(
      'Please answer this question to continue.',
      name: 'pleaseAnswerToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Failed to generate plan. Please try again.`
  String get planGenerationFailed {
    return Intl.message(
      'Failed to generate plan. Please try again.',
      name: 'planGenerationFailed',
      desc: '',
      args: [],
    );
  }

  /// `🎉 Plan activated!`
  String get planActivatedTitle {
    return Intl.message(
      '🎉 Plan activated!',
      name: 'planActivatedTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} habits added to your tracker.`
  String planActivatedDesc(int count) {
    return Intl.message(
      '$count habits added to your tracker.',
      name: 'planActivatedDesc',
      desc: '',
      args: [count],
    );
  }

  /// `Sports & Fitness`
  String get categorySports {
    return Intl.message(
      'Sports & Fitness',
      name: 'categorySports',
      desc: '',
      args: [],
    );
  }

  /// `Build a consistent fitness routine`
  String get categorySportsDesc {
    return Intl.message(
      'Build a consistent fitness routine',
      name: 'categorySportsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition`
  String get categoryNutrition {
    return Intl.message(
      'Nutrition',
      name: 'categoryNutrition',
      desc: '',
      args: [],
    );
  }

  /// `Improve your diet and reach your health goals`
  String get categoryNutritionDesc {
    return Intl.message(
      'Improve your diet and reach your health goals',
      name: 'categoryNutritionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Study`
  String get categoryStudy {
    return Intl.message(
      'Study',
      name: 'categoryStudy',
      desc: '',
      args: [],
    );
  }

  /// `Boost your academic performance`
  String get categoryStudyDesc {
    return Intl.message(
      'Boost your academic performance',
      name: 'categoryStudyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Learn a New Skill`
  String get categoryLearning {
    return Intl.message(
      'Learn a New Skill',
      name: 'categoryLearning',
      desc: '',
      args: [],
    );
  }

  /// `Master any skill step by step`
  String get categoryLearningDesc {
    return Intl.message(
      'Master any skill step by step',
      name: 'categoryLearningDesc',
      desc: '',
      args: [],
    );
  }

  /// `Habit Tracker`
  String get dailyReminderTitle {
    return Intl.message(
      'Habit Tracker',
      name: 'dailyReminderTitle',
      desc: '',
      args: [],
    );
  }

  /// `Time to check your habits!`
  String get dailyReminderBody {
    return Intl.message(
      'Time to check your habits!',
      name: 'dailyReminderBody',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
