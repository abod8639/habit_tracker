import 'package:flutter/material.dart';
import 'package:habit_tracker/features/home/presentation/pages/phone.dart';
import 'package:habit_tracker/features/home/presentation/pages/tablet.dart';
import 'package:habit_tracker/core/utils/responsive_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.isPhone(context) ? const Phone() : const Tablet();
  }
}
