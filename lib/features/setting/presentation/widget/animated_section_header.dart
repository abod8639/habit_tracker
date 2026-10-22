import 'dart:math' as math;

import 'package:flutter/material.dart';

Widget buildAnimatedSectionHeader(
  AnimationController animationController,
  BuildContext context,
  String title,
  int index,
) {
  final Animation<double> animation = CurvedAnimation(
    parent: animationController,
    curve: Interval(
      0.05 * (index % 10),
      math.min(0.05 * (index % 10) + 0.5, 1.0),
      curve: Curves.easeOutCubic,
    ),
  );

  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(animation),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
      ),
    ),
  );
}
