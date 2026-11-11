import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Display names of roles and tiers, from the l10n files.
String roleLabel(AppLocalizations l10n, Role role) => switch (role) {
      Role.guest => l10n.demoGuest,
      Role.booker => l10n.roleBooker,
      Role.trainer => l10n.roleTrainer,
      Role.facilityManager => l10n.roleFacilityManager,
      Role.verifier => l10n.roleVerifier,
      Role.unitAdmin => l10n.roleUnitAdmin,
      Role.superAdmin => l10n.roleSuperAdmin,
      Role.viewer => l10n.roleViewer,
    };

String tierLabel(AppLocalizations l10n, PriceTier tier) => switch (tier) {
      PriceTier.internal => l10n.tierInternal,
      PriceTier.external => l10n.tierExternal,
    };
