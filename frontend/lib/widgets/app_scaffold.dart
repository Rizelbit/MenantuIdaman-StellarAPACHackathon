import 'package:flutter/material.dart';
import '../app/theme.dart';
import 'buttons.dart';

/// Pembungkus halaman standar. Pakai ini di setiap screen agar padding, judul,
/// dan tombol bawah konsisten. Screen hasil agent cukup isi [child] + [bottom].
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? bottom; // tombol aksi utama, disematkan di bawah
  final bool scrollable;
  final List<Widget>? actions;
  final Widget? leading;

  const AppScaffold({
    super.key,
    this.title,
    required this.child,
    this.bottom,
    this.scrollable = true,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: AppSpacing.screen, child: child);
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), actions: actions, leading: leading),
      body: SafeArea(
        top: title == null,
        child: scrollable
            ? SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: body)
            : body,
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: bottom!,
            ),
    );
  }
}

/// Bottom sheet "sentuh Face ID untuk konfirmasi". Menyeragamkan momen sign.
/// Copy sengaja bank-like: "Konfirmasi dengan Face ID", bukan "sign transaction".
Future<bool> showBiometricConfirmSheet(
  BuildContext context, {
  required String headline,
  required String subline,
}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: AppRadii.sheet),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
                color: AppColors.surfaceAlt, shape: BoxShape.circle),
            child: const Icon(Icons.fingerprint,
                size: 34, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(headline, style: AppText.h2, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(subline, style: AppText.bodyMuted, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Konfirmasi dengan Face ID',
            icon: Icons.face_retouching_natural,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
          GhostButton(
              label: 'Batal', onPressed: () => Navigator.of(ctx).pop(false)),
        ],
      ),
    ),
  );
  return ok ?? false;
}
