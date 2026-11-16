import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';

/// The price tier of [user] at [now]: internal only with an approved,
/// unexpired verification and an `active` user, otherwise external (BR-21,
/// BR-24, BR-25, FR-040, research R9).
PriceTier tierFor(User? user, Verification? verification, DateTime now) =>
    user != null &&
        user.status == UserStatus.active &&
        verification != null &&
        verification.isActiveAt(now)
    ? PriceTier.internal
    : PriceTier.external;
