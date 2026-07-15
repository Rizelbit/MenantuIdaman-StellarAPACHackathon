import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';
import 'glow_background.dart';
import 'icon_button.dart';

/// Standard page shell. Matches the Claude design reference: an inline header
/// row (circular back button + title, optional trailing circular actions)
/// rather than a Material [AppBar], consistent screen padding, and an optional
/// pinned bottom CTA. No bottom navigation bar.
///
/// The back button is wired to `context.pop()` and only appears when the route
/// can actually pop, so it always works and never strands the user.
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? bottom;
  final bool scrollable;

  /// History-style oversized title (no back button by default reads as a top
  /// destination). Still shows back when the route was pushed.
  final bool largeTitle;

  /// Force-hide the back button even when the route can pop.
  final bool showBack;

  /// Trailing circular header actions (e.g. search, filter). Rendered at the
  /// right edge of the header row.
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    this.title,
    required this.child,
    this.bottom,
    this.scrollable = true,
    this.largeTitle = false,
    this.showBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final header = title == null ? null : _buildHeader(context);

    final columnChildren = <Widget>[
      if (header != null) ...[
        const SizedBox(height: KSpace.xs),
        header,
      ],
      if (scrollable) child else Expanded(child: child),
    ];

    final content = Padding(
      padding: KSpace.screenH,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnChildren,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: GlowBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: scrollable
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: KSpace.xl),
                    child: content,
                  )
                : content,
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

  Widget _buildHeader(BuildContext context) {
    final p = KColors.of(Theme.of(context).brightness);
    final canPop = context.canPop();
    final titleStyle = TextStyle(
      fontFamily: 'Manrope',
      fontSize: largeTitle ? 26 : 19,
      fontWeight: FontWeight.w700,
      letterSpacing: largeTitle ? -1.0 : -0.5,
      color: p.ink,
    );

    return Row(
      children: [
        if (showBack && canPop) ...[
          CircleIconButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: KSpace.md),
        ],
        Expanded(
          child: Text(title!, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        if (actions != null)
          for (final action in actions!) ...[
            const SizedBox(width: KSpace.xs),
            action,
          ],
      ],
    );
  }
}
