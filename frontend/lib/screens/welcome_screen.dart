import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../app/env.dart';
import '../app/router.dart';
import '../state/auth_controller.dart';
import '../theme/tokens.dart';

/// Welcome / Face ID login — the single entry surface shown before Home when
/// the user isn't signed in. No onboarding: one biometric prompt, with a
/// passcode fallback. Brand-fixed dark (near-black), Manrope throughout.
///
/// The visible biometric gate uses `local_auth` (native Face ID / Touch ID).
/// On success the actual session is created via the existing auth flow
/// (`registerWithPasskey`), which in mock mode completes instantly, so the
/// screen stays navigable on devices without biometric hardware.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  // Dark, brand-fixed palette (matches the design tokens' dark ramp exactly).
  static const _canvas = Color(0xFF090909);
  static const _surface = Color(0xFF1C1C1C);
  static const _accent = Color(0xFF0099FF);
  static const _ink = Color(0xFFFFFFFF);
  static const _muted = Color(0xFF999999);

  bool _busy = false;
  int _attempts = 0;
  String? _error;

  Future<bool> _promptBiometric() async {
    final auth = LocalAuthentication();
    try {
      // No biometric hardware (desktop / emulator): in prototype/mock mode let
      // the demo through; otherwise the user falls back to the passcode.
      if (!await auth.isDeviceSupported()) return Env.useMock;
      return await auth.authenticate(
        localizedReason: 'Log in to Kirimin with Face ID',
        // Allow the device passcode as a fallback to Face ID.
        biometricOnly: false,
        // Retry rather than fail if the app is backgrounded mid-prompt
        // (local_auth 3.x renamed the old `stickyAuth`).
        persistAcrossBackgrounding: true,
      );
    } on MissingPluginException {
      // No native biometric channel at all (desktop / test / unsupported
      // platform): behave like "no hardware" so the mock demo stays navigable.
      return Env.useMock;
    } on Object {
      // Cancelled, locked out, or not enrolled — a genuine failed attempt.
      return false;
    }
  }

  Future<void> _loginWithFaceId() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final ok = await _promptBiometric();
    if (!ok) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _attempts++;
        _error = _attempts >= 2
            ? 'Face ID didn\'t work. Try again or use your passcode.'
            : 'Face ID cancelled. Try again.';
      });
      return;
    }

    // Biometric passed → create the session (mock-friendly). The router
    // redirect moves to Home once signed in; we also push it explicitly.
    final failure = await ref
        .read(authControllerProvider.notifier)
        .registerWithPasskey('Kirimin User');
    if (!mounted) return;
    if (failure == null) {
      context.goNamed(Routes.home);
    } else {
      setState(() {
        _busy = false;
        _error = failure.message;
      });
    }
  }

  void _usePasscode() => context.pushNamed(Routes.passcode);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _canvas,
      ),
      child: Scaffold(
        backgroundColor: _canvas,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.6, -0.92), // ~20% / 4%
              radius: 1.35, // ~135% width ellipse
              colors: [Color(0xFF1A160F), Color(0xFF0E0C0A), _canvas],
              stops: [0.0, 0.45, 0.8],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                children: [
                  // --- Brand block, upper-middle ---
                  const Spacer(flex: 5),
                  const _SendBadge(),
                  const SizedBox(height: 18),
                  const Text(
                    'Kirimin',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.9,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SizedBox(
                    width: 220,
                    child: Text(
                      'Send to family and split bills without the hassle.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                        color: _muted,
                      ),
                    ),
                  ),
                  const Spacer(flex: 6),

                  // --- Bottom-anchored login group ---
                  Container(
                    width: KSize.iconTileLg,
                    height: KSize.iconTileLg,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(KRadius.xxl),
                    ),
                    child: const Center(child: _FaceIdGlyph()),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Log in with Face ID',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _muted,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _busy ? null : _loginWithFaceId,
                      style: TextButton.styleFrom(
                        backgroundColor: _ink,
                        disabledBackgroundColor: const Color(0xFFCFCFCF),
                        foregroundColor: _canvas,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _canvas,
                              ),
                            )
                          : const Text(
                              'Log in with Face ID',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _canvas,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _busy ? null : _usePasscode,
                    child: const Text(
                      'Use passcode instead',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 64px blue circle with a white up-right "send" arrow (the Kirimin mark).
class _SendBadge extends StatelessWidget {
  const _SendBadge();

  @override
  Widget build(BuildContext context) => Container(
        width: KSize.brandBadge,
        height: KSize.brandBadge,
        decoration: const BoxDecoration(
          color: Color(0xFF0099FF),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CustomPaint(painter: _SendArrowPainter()),
          ),
        ),
      );
}

/// Diagonal up-right arrow in a 24×24 box, stroke 2.2, rounded caps.
class _SendArrowPainter extends CustomPainter {
  const _SendArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Offset p(double x, double y) => Offset(x * s, y * s);

    // Shaft: bottom-left → top-right.
    canvas.drawLine(p(6, 18), p(18, 6), paint);
    // Arrow head: horizontal + vertical strokes from the tip.
    final head = Path()
      ..moveTo(p(9, 6).dx, p(9, 6).dy)
      ..lineTo(p(18, 6).dx, p(18, 6).dy)
      ..lineTo(p(18, 15).dx, p(18, 15).dy);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(covariant _SendArrowPainter oldDelegate) => false;
}

/// Face ID glyph: corner brackets, two eyes, nose, and a smile — accent blue.
class _FaceIdGlyph extends StatelessWidget {
  const _FaceIdGlyph();

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 34,
        height: 34,
        child: CustomPaint(painter: _FaceIdPainter()),
      );
}

class _FaceIdPainter extends CustomPainter {
  const _FaceIdPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 34.0;
    final paint = Paint()
      ..color = const Color(0xFF0099FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Offset p(double x, double y) => Offset(x * s, y * s);
    const arm = 6.0; // corner bracket arm length
    const r = 3.0; // bracket corner radius

    // Four rounded corner brackets.
    void corner(double cx, double cy, double dx, double dy) {
      final path = Path()
        ..moveTo(p(cx + dx * arm, cy).dx, p(cx + dx * arm, cy).dy)
        ..lineTo(p(cx + dx * r, cy).dx, p(cx + dx * r, cy).dy)
        ..quadraticBezierTo(p(cx, cy).dx, p(cx, cy).dy, p(cx, cy + dy * r).dx,
            p(cx, cy + dy * r).dy)
        ..lineTo(p(cx, cy + dy * arm).dx, p(cx, cy + dy * arm).dy);
      canvas.drawPath(path, paint);
    }

    corner(3, 3, 1, 1); // top-left
    corner(31, 3, -1, 1); // top-right
    corner(3, 31, 1, -1); // bottom-left
    corner(31, 31, -1, -1); // bottom-right

    // Eyes.
    canvas.drawLine(p(13, 13), p(13, 16), paint);
    canvas.drawLine(p(21, 13), p(21, 16), paint);
    // Nose.
    final nose = Path()
      ..moveTo(p(17, 14).dx, p(17, 14).dy)
      ..lineTo(p(17, 19).dx, p(17, 19).dy)
      ..lineTo(p(19, 19).dx, p(19, 19).dy);
    canvas.drawPath(nose, paint);
    // Smile.
    final smile = Path()
      ..moveTo(p(13, 23).dx, p(13, 23).dy)
      ..quadraticBezierTo(
          p(17, 26).dx, p(17, 26).dy, p(21, 23).dx, p(21, 23).dy);
    canvas.drawPath(smile, paint);
  }

  @override
  bool shouldRepaint(covariant _FaceIdPainter oldDelegate) => false;
}
