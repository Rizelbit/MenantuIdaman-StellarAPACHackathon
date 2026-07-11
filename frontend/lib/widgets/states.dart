import 'package:flutter/material.dart';
import '../app/theme.dart';
import 'buttons.dart';

/// Loading, error, dan empty — ditulis sebagai ARAHAN, bukan mood.
/// Error tidak minta maaf & tidak samar; empty adalah ajakan bertindak.

class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(message!, style: AppText.bodyMuted),
            ],
          ],
        ),
      );
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.danger, size: 40),
              const SizedBox(height: AppSpacing.lg),
              Text(message, style: AppText.body, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(label: 'Coba lagi', onPressed: onRetry),
              ],
            ],
          ),
        ),
      );
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: AppText.h2, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle,
                  style: AppText.bodyMuted, textAlign: TextAlign.center),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      );
}
