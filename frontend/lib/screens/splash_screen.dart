import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Splash netral saat router menentukan tujuan (onboarding vs home).
/// Untuk demo, ganti ikon/nama agar terasa "aplikasi keuangan", bukan crypto.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send_rounded, size: 56, color: AppColors.primary),
            SizedBox(height: AppSpacing.lg),
            Text('Kirimin', style: AppText.h1),
          ],
        ),
      ),
    );
  }
}
