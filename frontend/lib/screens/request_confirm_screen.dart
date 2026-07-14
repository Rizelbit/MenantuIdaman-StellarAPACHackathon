import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../state/request_controller.dart';
import '../theme/tokens.dart';
import '../widgets/widgets.dart';

/// Layar 2/3 alur minta: ringkasan permintaan sebelum dikirim. Tidak ada
/// Face ID di sini — beda dari alur kirim — karena meminta tidak memindahkan
/// dana apa pun, jadi ditegaskan lewat [_NoBiometricHint].
class RequestConfirmScreen extends ConsumerWidget {
  const RequestConfirmScreen({super.key});

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    await ref.read(requestControllerProvider.notifier).submit();
    if (!context.mounted) return;
    context.goNamed(Routes.requestSent);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(requestControllerProvider);
    final contact = state.fromContact;
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;

    if (contact == null) {
      return const AppScaffold(
        title: 'Konfirmasi permintaan',
        child: EmptyView(
          icon: Icons.request_page_outlined,
          title: 'Belum ada permintaan',
          subtitle: 'Kembali ke layar sebelumnya untuk isi kontak dan nominal dulu.',
        ),
      );
    }

    return AppScaffold(
      title: 'Konfirmasi permintaan',
      bottom: PrimaryPillButton(
        label: 'Kirim permintaan',
        onPressed: () => _submit(context, ref),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KSpace.md),
          SurfaceCard(
            elevated: true,
            child: Column(
              children: [
                Text('Kamu meminta',
                    style: text.bodyMedium?.copyWith(color: p.inkMuted)),
                const SizedBox(height: KSpace.xs),
                MoneyText(amountIdr: state.amountIdr, size: 40),
                const SizedBox(height: KSpace.xs),
                Text('dari ${contact.name}',
                    style: text.bodyMedium?.copyWith(color: p.inkMuted)),
                if (state.note.trim().isNotEmpty) ...[
                  const SizedBox(height: KSpace.md),
                  Text('«${state.note}»',
                      style: text.bodyMedium?.copyWith(
                        color: p.inkMuted,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
          const SizedBox(height: KSpace.md),
          const _NoBiometricHint(),
        ],
      ),
    );
  }
}

class _NoBiometricHint extends StatelessWidget {
  const _NoBiometricHint();

  @override
  Widget build(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(Icons.info_outline, size: 18, color: p.inkMuted),
        const SizedBox(width: KSpace.xs),
        Expanded(
          child: Text(
            'Tanpa Face ID — tidak ada dana yang berpindah',
            style: text.bodySmall?.copyWith(color: p.inkMuted),
          ),
        ),
      ],
    );
  }
}
