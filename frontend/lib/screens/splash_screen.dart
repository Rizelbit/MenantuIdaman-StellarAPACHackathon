import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Splash netral saat router menentukan tujuan (onboarding vs home).
/// Router redirects away once auth state resolves — no navigation here.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    return GlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_outward, color: Colors.white, size: 24),
              ),
              const SizedBox(height: KSpace.lg),
              Text('Kirimin', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: KSpace.xl),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: p.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
