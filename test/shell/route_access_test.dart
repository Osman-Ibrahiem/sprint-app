import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/app_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/features/identity/domain/app_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../helpers/pump_app.dart';

/// Route-level access rules and the `from` return path (FR-016 – FR-018,
/// contracts/routes.md rules 2, 3, 5).
void main() {
  Widget stub(String text) => Text(text);

  Future<(GoRouter, ProviderContainer)> pump(WidgetTester tester) async {
    setWindow(tester);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(sessionProvider.future);
    final refresh = ValueNotifier<int>(0);
    addTearDown(refresh.dispose);
    container.listen(currentSessionProvider, (_, _) => refresh.value++);

    final router = buildAppRouter(
      session: () => container.read(currentSessionProvider),
      refreshListenable: refresh,
      destinations: [
        ...baseDestinations,
        ShellDestination(
          name: 'verification',
          path: AppPaths.verification,
          icon: Icons.verified,
          selectedIcon: Icons.verified,
          label: (l) => l.navHome,
          builder: () => stub('queue'),
          access: const RouteAccess(requiredSection: AppSection.verification),
        ),
      ],
      extraRoutes: [
        GoRoute(path: AppPaths.signIn, builder: (_, _) => stub('sign-in page')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: SprintTheme.light,
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (router, container);
  }

  // The session's expiry timer must be gone before the test ends.
  Future<void> finish(WidgetTester tester, ProviderContainer c) async {
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  }

  String where(GoRouter r) =>
      r.routerDelegate.currentConfiguration.uri.toString();

  testWidgets('a guest deep link goes to sign-in with from, then back', (
    tester,
  ) async {
    final (router, c) = await pump(tester);
    router.go(AppPaths.verification);
    await tester.pumpAndSettle();
    expect(where(router), '${AppPaths.signIn}?from=%2Fverification');

    await c.read(sessionProvider.notifier).actAs(SeedIds.verifier);
    await tester.pumpAndSettle();
    expect(where(router), AppPaths.verification);
    expect(find.text('queue'), findsOneWidget);
    await finish(tester, c);
  });

  testWidgets('a signed-in person without the section sees NoAccessScreen', (
    tester,
  ) async {
    final (router, c) = await pump(tester);
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
    router.go(AppPaths.verification);
    await tester.pumpAndSettle();
    expect(where(router), AppPaths.verification);
    expect(find.byType(NoAccessScreen), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    await finish(tester, c);
  });

  testWidgets('sign out re-evaluates the open gated route', (tester) async {
    final (router, c) = await pump(tester);
    final n = c.read(sessionProvider.notifier);
    await n.actAs(SeedIds.verifier);
    router.go(AppPaths.verification);
    await tester.pumpAndSettle();
    expect(find.text('queue'), findsOneWidget);

    await n.signOut();
    await tester.pumpAndSettle();
    expect(where(router), startsWith(AppPaths.signIn));
    await finish(tester, c);
  });

  testWidgets('an unsafe or unknown from falls back to Home', (tester) async {
    final (router, c) = await pump(tester);
    for (final from in [
      'https://evil.example/x',
      '//evil.example',
      '/nowhere',
      AppPaths.signIn,
    ]) {
      await c.read(sessionProvider.notifier).actAs(null);
      router.go(AppPaths.signInFrom(from));
      await tester.pumpAndSettle();
      await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
      await tester.pumpAndSettle();
      expect(where(router), AppPaths.home, reason: from);
    }
    await finish(tester, c);
  });

  testWidgets('a known in-app from is kept', (tester) async {
    final (router, c) = await pump(tester);
    router.go(AppPaths.signInFrom(AppPaths.facilities));
    await tester.pumpAndSettle();
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
    await tester.pumpAndSettle();
    expect(where(router), AppPaths.facilities);
    await finish(tester, c);
  });
}
