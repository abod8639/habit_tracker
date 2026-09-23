import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: analytics);
  }

  TimeTrackerObserver getTimeTrackerObserver() {
    return TimeTrackerObserver(this);
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logTap(double x, double y, String currentRoute) async {
    await logEvent(
      'screen_tap',
      parameters: {
        'x_coordinate': x,
        'y_coordinate': y,
        'route_name': currentRoute,
      },
    );
  }

  Future<void> logTimeSpent(String screenName, int seconds) async {
    await logEvent(
      'page_time_spent',
      parameters: {
        'screen_name': screenName,
        'duration_seconds': seconds,
      },
    );
  }

  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  Future<void> logLogin(String loginMethod) async {
    await analytics.logLogin(loginMethod: loginMethod);
  }

  Future<void> logSignUp(String signUpMethod) async {
    await analytics.logSignUp(signUpMethod: signUpMethod);
  }

  Future<void> setUserId(String id) async {
    await analytics.setUserId(id: id);
  }

  Future<void> setUserProperty(String name, String value) async {
    await analytics.setUserProperty(name: name, value: value);
  }
}

class TimeTrackerObserver extends RouteObserver<PageRoute<dynamic>> {
  final AnalyticsService analyticsService;
  final Map<String, DateTime> _routeStartTime = {};

  TimeTrackerObserver(this.analyticsService);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      _routeStartTime[route.settings.name!] = DateTime.now();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logTimeSpent(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      _logTimeSpent(oldRoute);
    }
    if (newRoute?.settings.name != null) {
      _routeStartTime[newRoute!.settings.name!] = DateTime.now();
    }
  }

  void _logTimeSpent(Route<dynamic> route) {
    if (route.settings.name != null &&
        _routeStartTime.containsKey(route.settings.name)) {
      final startTime = _routeStartTime[route.settings.name]!;
      final duration = DateTime.now().difference(startTime).inSeconds;

      // Only log if the duration is significant (e.g. > 0 seconds)
      if (duration > 0) {
        analyticsService.logTimeSpent(route.settings.name!, duration);
      }

      _routeStartTime.remove(route.settings.name);
    }
  }
}
