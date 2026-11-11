import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_text.g.dart';

/// App bar that follows the platform (FR-019): centred title and chevron back
/// on Apple, start-aligned title and arrow back elsewhere. The back button
/// shows only when the route can pop.
///
/// For a large title on top-level screens use [AdaptiveSliverAppBar].
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    required this.title,
    this.leading,
    this.actions = const [],
    super.key,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Size get preferredSize => Size.fromHeight(
        adaptiveStyleOfHost() == AdaptiveStyle.apple
            ? kMinInteractiveDimensionCupertino
            : kToolbarHeight,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    if (adaptiveStyleOf(context) == AdaptiveStyle.apple) {
      return CupertinoNavigationBar(
        middle: Text(title),
        leading: leading,
        automaticallyImplyLeading: leading == null && canPop,
        trailing: actions.isEmpty
            ? null
            : Row(mainAxisSize: MainAxisSize.min, children: actions),
        backgroundColor: colors.surface,
        border: Border(bottom: BorderSide(color: colors.line)),
      );
    }
    return AppBar(
      title: Text(title, style: SprintText.title.copyWith(color: colors.ink)),
      centerTitle: false,
      leading: leading,
      automaticallyImplyLeading: leading == null,
      actions: actions,
    );
  }
}

/// Sliver version: a large collapsing title on Apple platforms when
/// [largeTitle] is set, a plain pinned bar elsewhere.
class AdaptiveSliverAppBar extends StatelessWidget {
  const AdaptiveSliverAppBar({
    required this.title,
    this.largeTitle = false,
    this.leading,
    this.actions = const [],
    super.key,
  });

  final String title;
  final bool largeTitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    if (adaptiveStyleOf(context) == AdaptiveStyle.apple) {
      final trailing = actions.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: actions);
      if (largeTitle) {
        return CupertinoSliverNavigationBar(
          largeTitle: Text(title),
          leading: leading,
          automaticallyImplyLeading: leading == null && canPop,
          trailing: trailing,
          backgroundColor: colors.surface,
          border: Border(bottom: BorderSide(color: colors.line)),
        );
      }
      return SliverPersistentHeader(
        pinned: true,
        delegate: _FixedBarDelegate(
          AdaptiveAppBar(title: title, leading: leading, actions: actions),
        ),
      );
    }
    return SliverAppBar(
      pinned: true,
      title: Text(title, style: SprintText.title.copyWith(color: colors.ink)),
      centerTitle: false,
      leading: leading,
      automaticallyImplyLeading: leading == null,
      actions: actions,
    );
  }
}

class _FixedBarDelegate extends SliverPersistentHeaderDelegate {
  _FixedBarDelegate(this.bar);
  final AdaptiveAppBar bar;

  @override
  double get minExtent => bar.preferredSize.height;
  @override
  double get maxExtent => bar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      bar;

  @override
  bool shouldRebuild(_FixedBarDelegate oldDelegate) => oldDelegate.bar != bar;
}
