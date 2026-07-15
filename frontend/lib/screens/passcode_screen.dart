import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../state/auth_controller.dart';

/// Passcode fallback (stub) — reached from "Use passcode instead" on Welcome.
/// Collects a 6-digit PIN and, once complete, signs in via the same session
/// flow as Face ID. Intentionally minimal; real PIN verification is a backend
/// concern (see docs/backend_handoff.md).
class PasscodeScreen extends ConsumerStatefulWidget {
  const PasscodeScreen({super.key});

  @override
  ConsumerState<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends ConsumerState<PasscodeScreen> {
  static const _canvas = Color(0xFF090909);
  static const _accent = Color(0xFF0099FF);
  static const _ink = Color(0xFFFFFFFF);
  static const _muted = Color(0xFF999999);
  static const _length = 6;

  String _pin = '';
  bool _busy = false;

  void _onKey(String d) {
    if (_busy || _pin.length >= _length) return;
    setState(() => _pin += d);
    if (_pin.length == _length) _submit();
  }

  void _onBackspace() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final failure = await ref
        .read(authControllerProvider.notifier)
        .registerWithPasskey('Kirimin User');
    if (!mounted) return;
    if (failure == null) {
      context.goNamed(Routes.home);
    } else {
      setState(() {
        _busy = false;
        _pin = '';
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _canvas,
      ),
      child: Scaffold(
        backgroundColor: _canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: _ink,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const Text(
                  'Enter passcode',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your 6-digit PIN to log in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 15, color: _muted),
                ),
                const SizedBox(height: 32),
                // PIN dots.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_length, (i) {
                    final filled = i < _pin.length;
                    return Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? _accent : Colors.transparent,
                        border: Border.all(
                          color: filled ? _accent : _muted,
                          width: 1.4,
                        ),
                      ),
                    );
                  }),
                ),
                const Spacer(flex: 2),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _accent),
                  )
                else
                  _PinPad(onKey: _onKey, onBackspace: _onBackspace),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple 3×4 numeric pad: 1-9, then blank / 0 / backspace.
class _PinPad extends StatelessWidget {
  final void Function(String) onKey;
  final VoidCallback onBackspace;
  const _PinPad({required this.onKey, required this.onBackspace});

  static const _ink = Color(0xFFFFFFFF);
  static const _surface = Color(0xFF1C1C1C);

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Material(
            color:
                label.isEmpty && child == null ? Colors.transparent : _surface,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: child ??
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
              ),
            ),
          ),
        ),
      );
    }

    Widget row(List<Widget> children) =>
        Row(mainAxisAlignment: MainAxisAlignment.center, children: children);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([
          for (final d in ['1', '2', '3']) key(d, onTap: () => onKey(d))
        ]),
        row([
          for (final d in ['4', '5', '6']) key(d, onTap: () => onKey(d))
        ]),
        row([
          for (final d in ['7', '8', '9']) key(d, onTap: () => onKey(d))
        ]),
        row([
          key(''),
          key('0', onTap: () => onKey('0')),
          key('',
              onTap: onBackspace,
              child: const Icon(Icons.backspace_outlined, color: _ink)),
        ]),
      ],
    );
  }
}
