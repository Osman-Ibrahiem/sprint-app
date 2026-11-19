import 'package:sprint/features/identity/domain/role_assignment.dart';

/// A top-level area of the app. Which ones a person gets is data computed from
/// their roles, not navigation code (FR-007). The base five are for everyone; the shell hides notifications from guests.
enum AppSection {
  home,
  facilities,
  bookings,
  notifications,
  profile,
  trainerSessions,
  facilityOps,
  verification,
  administration,
  reports,
}

/// The sections for these assignments, in enum order, without duplicates. A
/// guest (no assignments) and a booker get the base four.
List<AppSection> sectionsFor(Iterable<RoleAssignment> assignments) {
  final sections = <AppSection>{
    AppSection.home,
    AppSection.facilities,
    AppSection.bookings,
    // Always a route, so signing in never rebuilds the router; the shell shows
    // it only to a signed-in person, and not in the compact tab bar (R1).
    AppSection.notifications,
    AppSection.profile,
  };
  for (final a in assignments) {
    switch (a.role) {
      case Role.trainer:
        sections.add(AppSection.trainerSessions);
      case Role.facilityManager:
        sections.add(AppSection.facilityOps);
      case Role.verifier:
        sections.add(AppSection.verification);
      case Role.superAdmin:
        // Super admins also review verification requests (research R10).
        sections.addAll({AppSection.administration, AppSection.verification});
      case Role.unitAdmin:
        sections.add(AppSection.administration);
      case Role.viewer:
        sections.add(AppSection.reports);
      case Role.guest || Role.booker:
        break;
    }
  }
  return AppSection.values.where(sections.contains).toList();
}
