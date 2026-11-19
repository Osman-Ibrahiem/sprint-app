import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/notification_bell/notification_bell.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/notifications/presentation/providers/notification_providers.dart';

/// The header of the four root screens: the title and, on compact for a
/// signed-in person, the notification bell at the end (FR-NTF-02). From the
/// medium class the destination carries the badge instead, and a guest has
/// neither. While the count loads the bell shows no badge.
class RootHeader extends ConsumerWidget {
  const RootHeader({required this.title, super.key});

  /// Usually a `Text` in the screen's title style.
  final Widget title;

  static const bellKey = ValueKey<String>('root-header-bell');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = !ref.watch(currentSessionProvider).isGuest;
    final showBell = signedIn && WindowSize.of(context).isCompact;
    return Row(
      children: [
        Expanded(child: Semantics(header: true, child: title)),
        if (showBell) ...[
          const SizedBox(width: SprintSpacing.space3),
          NotificationBell(
            key: bellKey,
            unread: ref.watch(unreadCountProvider),
            onTap: () => context.go(AppPaths.notifications),
          ),
        ],
      ],
    );
  }
}
