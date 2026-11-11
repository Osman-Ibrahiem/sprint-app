import 'package:sprint/features/identity/domain/role_assignment.dart';

/// A top-level area of the app. Which ones a person gets is data computed from
/// their roles, not navigation code (FR-007). The first four are for everyone.
enum AppSection {
  home,
  facilities,
  bookings,
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
      case Role.unitAdmin || Role.superAdmin:
        sections.add(AppSection.administration);
      case Role.viewer:
        sections.add(AppSection.reports);
      case Role.guest || Role.booker:
        break;
    }
  }
  return AppSection.values.where(sections.contains).toList();
}
