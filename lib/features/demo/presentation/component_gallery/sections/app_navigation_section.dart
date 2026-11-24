import 'package:flutter/material.dart';
import 'package:sprint/core/widgets/app_navigation/app_navigation.dart';
import 'package:sprint/core/widgets/app_navigation/nav_destination.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Each navigation form forced, for guest and for a signed-in booker with a
/// notification badge (FR-048 – FR-056).
class AppNavigationSection extends StatelessWidget {
  const AppNavigationSection({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final guest = _destinations(badge: 0);
    final booker = _destinations(badge: 3);
    final six = [
      ...guest,
      NavDestination(
        label: l10n.navMore,
        icon: Icons.help_outline,
        selectedIcon: Icons.help,
      ),
      NavDestination(
        label: l10n.appName,
        icon: Icons.info_outline,
        selectedIcon: Icons.info,
      ),
    ];

    return GallerySection(
      title: l10n.galleryNavigationSection,
      caption: l10n.gallerySampleNote,
      children: [
        for (final form in NavigationForm.values) ...[
          GalleryRow(
            label: '${form.name} · ${l10n.demoGuest}',
            child: _box(
              form,
              guest,
              height: form == NavigationForm.tabBar ? 120 : 320,
            ),
          ),
          GalleryRow(
            label: '${form.name} · ${l10n.navAccount}',
            child: _box(
              form,
              booker,
              height: form == NavigationForm.tabBar ? 120 : 360,
            ),
          ),
          GalleryRow(
            label: '${form.name} · 6',
            child: _box(
              form,
              six,
              height: form == NavigationForm.tabBar ? 120 : 400,
            ),
          ),
        ],
      ],
    );
  }

  List<NavDestination> _destinations({required int badge}) => [
        NavDestination(
          label: l10n.navHome,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        NavDestination(
          label: l10n.navFacilities,
          icon: Icons.square_outlined,
          selectedIcon: Icons.square,
        ),
        NavDestination(
          label: l10n.navBookings,
          icon: Icons.confirmation_number_outlined,
          selectedIcon: Icons.confirmation_number,
          badgeCount: badge,
        ),
        NavDestination(
          label: l10n.navAccount,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
      ];

  Widget _box(
    NavigationForm form,
    List<NavDestination> destinations, {
    required double height,
  }) {
    return SizedBox(
      width: form == NavigationForm.sidebar ? 260 : 400,
      height: height,
      child: AppNavigation(
        destinations: destinations,
        selected: 0,
        onSelected: (_) {},
        form: form,
      ),
    );
  }
}
