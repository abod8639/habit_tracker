import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/features/home/presentation/pages/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAuthState = ref.watch(authNotifierProvider);

    return asyncAuthState.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
      error: (e, _) => const LoginPage(),
      data: (authState) {
        if (authState.isLoggedIn || authState.hasSkippedLogin) {
          return const HomeScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
