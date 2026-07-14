import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens.dart';
import 'glow_background.dart';

/// Standard page shell. Every screen uses this for consistent padding, optional
/// title/back, and an optional pinned bottom CTA. No bottom navigation bar.
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? bottom;
  final bool scrollable;
  final Widget? leading;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    this.title,
    required this.child,
    this.bottom,
    this.scrollable = true,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final body = Padding(padding: KSpace.screenH, child: child);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: GlowBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: title == null
              ? null
              : AppBar(title: Text(title!), leading: leading, actions: actions),
          body: SafeArea(
            top: title == null,
            child: scrollable
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: KSpace.xl), child: body)
                : body,
          ),
          bottomNavigationBar: bottom == null
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(KSpace.lg, 0, KSpace.lg, KSpace.lg),
                  child: bottom!,
                ),
        ),
      ),
    );
  }
}
