import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Tombol aksi utama (design system §6.1). Satu per layar.
/// Pill kuning, teks near-black, gradient halus primaryHi → primary, tekan =
/// primaryPressed + scale 0.98. Label = tindakan yang terjadi ("Kirim sekarang"),
/// bukan "Submit". Loading = spinner near-black, tap dinonaktifkan.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final fg = enabled ? AppColors.onPrimary : AppColors.textTertiary;

    final Widget content = widget.loading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(AppColors.onPrimary),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: AppIconSize.md, color: fg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(widget.label, style: AppText.button.copyWith(color: fg)),
            ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            height: 56,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadii.button,
              // Depth tetap datar: gradient halus, bukan bayangan.
              gradient: enabled && !_pressed
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primaryHi, AppColors.primary],
                    )
                  : null,
              color: !enabled
                  ? AppColors.surfaceAlt
                  : (_pressed ? AppColors.primaryPressed : null),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Tombol sekunder (design system §6.2): transparan, garis hairlineStrong, teks
/// terang. Untuk "Batal", "Nanti saja" — tidak pernah bersaing dengan CTA kuning.
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const GhostButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
