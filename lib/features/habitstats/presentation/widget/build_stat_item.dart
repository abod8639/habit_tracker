import 'package:flutter/material.dart';
import 'package:habit_tracker/core/utils/responsive_utils.dart';

Widget buildStatItem(String title, String value, IconData icon, Color color) {
  return Expanded(
    child: Builder(
      builder: (context) {
        final mSize = MediaQuery.of(context).size.width * .035;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.09),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
          
                    size: ResponsiveUtils.isPhone(context) ? 18 : 22,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveUtils.isPhone(context) ? mSize : 18,
                      // color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
