import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';

/// The simulated provider page. For now it only resolves an unknown or
/// finished session (after a restart): back to the booking's checkout when
/// that is known, otherwise home, and it never starts a payment (FR-024).
/// The page itself arrives with T032.
class FakeGatewayScreen extends ConsumerWidget {
  const FakeGatewayScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final known = ref.watch(fakeGatewayProvider).session(sessionId);
    if (known == null) {
      final target = ref.watch(bookingOfSessionProvider(sessionId));
      return target.when(
        data: (t) => _Redirect(location: t ?? AppPaths.home),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const _Redirect(location: AppPaths.home),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Redirect extends StatefulWidget {
  const _Redirect({required this.location});
  final String location;

  @override
  State<_Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<_Redirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(widget.location);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
