import 'package:sprint/app/router/routes.dart';
import 'package:sprint/features/identity/domain/app_section.dart';

/// Which screen (if any) each section has. Only the base four exist in this
/// feature; later features register their own, and a section with no
/// registered screen simply does not appear.
final Map<AppSection, ShellDestination> baseRegistry = {
  AppSection.home: baseDestinations[0],
  AppSection.facilities: baseDestinations[1],
  AppSection.bookings: baseDestinations[2],
  AppSection.profile: baseDestinations[3],
};

/// The shell destinations for [sections], in order, limited to the ones that
/// have a registered screen (FR-007, FR-031).
List<ShellDestination> destinationsFor(
  List<AppSection> sections, {
  required Map<AppSection, ShellDestination> registry,
}) =>
    [
      for (final s in sections)
        if (registry[s] != null) registry[s]!,
    ];
