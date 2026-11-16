import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/auth/data/in_memory_auth_repository.dart';
import 'package:sprint/features/auth/data/simulated_mailbox.dart';
import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/domain/auth_repository.dart';
import 'package:sprint/features/auth/domain/credential.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/features/auth/domain/password_hasher.dart';
import 'package:sprint/features/identity/data/in_memory_identity_repository.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';

/// What the contract suite needs besides the repository: a way to move time,
/// to read the code the person would read in their mailbox, and to read roles.
/// A backend implementation supplies the same three.
class AuthHarness {
  AuthHarness({
    required this.auth,
    required this.advance,
    required this.latestCode,
    required this.rolesFor,
  });

  final AuthRepository auth;
  final void Function(Duration) advance;
  final String? Function(String email, CodePurpose purpose) latestCode;
  final Future<List<RoleAssignment>> Function(String userId) rolesFor;
}

/// Accounts every harness starts with. All use [seedPassword].
const seedPassword = 'Password1';
const activeEmail = 'sara.active@example.com';
const activePhone = '01012345678';
const suspendedEmail = 'sami.suspended@example.com';
const unconfirmedEmail = 'uma.unconfirmed@example.com';
const unconfirmedPhone = '01212345678';

final _t0 = DateTime.utc(2026, 11, 16, 9);

AuthHarness createInMemoryHarness() {
  var now = _t0;
  final clk = Clock(() => now);
  User person(String id, String email, String phone, UserStatus status) => User(
    id: id,
    name: 'اسم $id',
    phone: phone,
    email: email,
    createdAt: _t0,
    status: status,
  );
  final identity = InMemoryIdentityRepository(
    users: [
      person('u-active', activeEmail, activePhone, UserStatus.active),
      person('u-susp', suspendedEmail, '01112345678', UserStatus.suspended),
      person(
        'u-unconf',
        unconfirmedEmail,
        unconfirmedPhone,
        UserStatus.unconfirmed,
      ),
    ],
    roleAssignments: const [],
  );
  Credential cred(String id) {
    final h = PasswordHasher.hash(seedPassword);
    return Credential(userId: id, salt: h.salt, hash: h.hash);
  }

  final mailbox = SimulatedMailbox(
    template: (purpose, code) => (subject: purpose.name, body: 'code $code'),
  );
  final auth = InMemoryAuthRepository(
    identity: identity,
    mailbox: mailbox,
    clock: clk,
    credentials: [cred('u-active'), cred('u-susp'), cred('u-unconf')],
  );
  return AuthHarness(
    auth: auth,
    advance: (d) => now = now.add(d),
    latestCode: mailbox.latestCodeFor,
    rolesFor: identity.roleAssignments,
  );
}

Failure? _fail<T>(Result<T> r) => r.failureOrNull;

String _otherThan(String code) => code == '000000' ? '111111' : '000000';

void authRepositoryContract(String name, AuthHarness Function() create) {
  group('AuthRepository contract: $name', () {
    late AuthHarness h;
    late AuthRepository auth;
    setUp(() {
      h = create();
      auth = h.auth;
    });

    Future<String> signUpNew({
      String email = 'new.person@example.com',
      String phone = '01512345678',
    }) async {
      final r = await auth.signUp(
        name: 'منى أحمد',
        phone: phone,
        email: email,
        password: seedPassword,
      );
      expect(r.isOk, isTrue, reason: '$r');
      return email;
    }

    Future<Failure?> signIn(String id, String password) async =>
        _fail(await auth.signIn(identifier: id, password: password));

    group('signUp', () {
      test('creates an unconfirmed account and sends a code', () async {
        final r = await auth.signUp(
          name: 'منى أحمد',
          phone: '٠١٥١٢٣٤٥٦٧٨',
          email: ' New.Person@Example.com ',
          password: seedPassword,
        );
        final ok = r.valueOrThrow;
        expect(ok.email, 'new.person@example.com');
        expect(h.latestCode(ok.email, CodePurpose.confirmEmail), hasLength(6));
        expect(await auth.currentUserId(), isNull);
        expect(await signIn(ok.email, seedPassword), isA<NeedsConfirmation>());
      });

      test('invalid fields name the field', () async {
        Future<String?> field({
          String name = 'منى أحمد',
          String phone = '01512345678',
          String email = 'a@b.com',
          String password = seedPassword,
        }) async {
          final f = _fail(
            await auth.signUp(
              name: name,
              phone: phone,
              email: email,
              password: password,
            ),
          );
          return f is InvalidField ? f.field : null;
        }

        expect(await field(name: 'منى'), 'name');
        expect(await field(phone: '123'), 'phone');
        expect(await field(email: 'nope'), 'email');
        expect(await field(password: 'short'), 'password');
      });

      test('email and phone are unique after normalising', () async {
        final byEmail = await auth.signUp(
          name: 'منى أحمد',
          phone: '01512345678',
          email: ' SARA.ACTIVE@example.com',
          password: seedPassword,
        );
        expect(_fail(byEmail), isA<EmailTaken>());
        final byPhone = await auth.signUp(
          name: 'منى أحمد',
          phone: '+20 101 234 5678',
          email: 'fresh@example.com',
          password: seedPassword,
        );
        expect(_fail(byPhone), isA<PhoneTaken>());
      });
    });

    group('confirmEmail', () {
      test(
        'signs in, activates and gives BOOKER at university scope',
        () async {
          final email = await signUpNew();
          final code = h.latestCode(email, CodePurpose.confirmEmail)!;
          final r = await auth.confirmEmail(email: email, code: code);
          final id = r.valueOrThrow.userId;
          expect(await auth.currentUserId(), id);
          final roles = await h.rolesFor(id);
          expect(roles, hasLength(1));
          expect(roles.single.role, Role.booker);
          expect(roles.single.scopeType, RoleScopeType.university);
          expect(roles.single.scopeId, isNull);
          // The code is used up and the account is no longer pending.
          final again = await auth.confirmEmail(email: email, code: code);
          expect(_fail(again), isA<NoPendingConfirmation>());
        },
      );

      test('a wrong code counts tries and five kill it', () async {
        final email = await signUpNew();
        final good = h.latestCode(email, CodePurpose.confirmEmail)!;
        final wrong = _otherThan(good);
        for (var i = 1; i < AuthLimits.maxCodeTries; i++) {
          final f = _fail(await auth.confirmEmail(email: email, code: wrong));
          expect((f as CodeWrong).triesLeft, AuthLimits.maxCodeTries - i);
        }
        expect(
          _fail(await auth.confirmEmail(email: email, code: wrong)),
          isA<CodeDead>(),
        );
        // Even the right code is dead now.
        expect(
          _fail(await auth.confirmEmail(email: email, code: good)),
          isA<CodeDead>(),
        );
        // A new code replaces the dead one after the wait.
        h.advance(AuthLimits.resendWait);
        final resent = await auth.resendCode(
          email: email,
          purpose: CodePurpose.confirmEmail,
        );
        expect(resent.isOk, isTrue);
        final fresh = h.latestCode(email, CodePurpose.confirmEmail)!;
        expect(
          (await auth.confirmEmail(email: email, code: fresh)).isOk,
          isTrue,
        );
      });

      test('a code expires after 15 minutes', () async {
        final email = await signUpNew();
        final code = h.latestCode(email, CodePurpose.confirmEmail)!;
        h.advance(AuthLimits.codeLife - const Duration(seconds: 1));
        expect(
          _fail(await auth.confirmEmail(email: email, code: _otherThan(code))),
          isA<CodeWrong>(),
        );
        h.advance(const Duration(seconds: 1));
        expect(
          _fail(await auth.confirmEmail(email: email, code: code)),
          isA<CodeExpired>(),
        );
      });

      test('unknown or already active emails have nothing pending', () async {
        expect(
          _fail(await auth.confirmEmail(email: 'who@example.com', code: '1')),
          isA<NoPendingConfirmation>(),
        );
        expect(
          _fail(await auth.confirmEmail(email: activeEmail, code: '123456')),
          isA<NoPendingConfirmation>(),
        );
      });
    });

    group('resendCode', () {
      test('waits 60 seconds, then replaces the code', () async {
        final email = await signUpNew();
        final first = h.latestCode(email, CodePurpose.confirmEmail)!;
        final tooSoon = await auth.resendCode(
          email: email,
          purpose: CodePurpose.confirmEmail,
        );
        expect(_fail(tooSoon), isA<ResendTooSoon>());
        expect(
          (_fail(tooSoon) as ResendTooSoon).wait,
          lessThanOrEqualTo(AuthLimits.resendWait),
        );
        h.advance(AuthLimits.resendWait);
        final ok = await auth.resendCode(
          email: email,
          purpose: CodePurpose.confirmEmail,
        );
        expect(ok.isOk, isTrue);
        final second = h.latestCode(email, CodePurpose.confirmEmail)!;
        if (second != first) {
          // The old code no longer works.
          expect(
            _fail(await auth.confirmEmail(email: email, code: first)),
            isA<CodeWrong>(),
          );
        }
        expect(
          (await auth.confirmEmail(email: email, code: second)).isOk,
          isTrue,
        );
      });

      test(
        'unknown email looks the same, including the wait (SC-009)',
        () async {
          final first = await auth.resendCode(
            email: 'ghost@example.com',
            purpose: CodePurpose.confirmEmail,
          );
          expect(first.isOk, isTrue);
          final second = await auth.resendCode(
            email: 'ghost@example.com',
            purpose: CodePurpose.confirmEmail,
          );
          expect(_fail(second), isA<ResendTooSoon>());
          expect(
            h.latestCode('ghost@example.com', CodePurpose.confirmEmail),
            isNull,
          );
        },
      );
    });

    group('signIn', () {
      test('by email or phone, normalised', () async {
        final r = await auth.signIn(
          identifier: ' SARA.Active@example.com ',
          password: seedPassword,
        );
        expect(r.valueOrThrow.userId, 'u-active');
        await auth.signOut();
        expect(await auth.currentUserId(), isNull);
        expect(await signIn('٠١٠١٢٣٤٥٦٧٨', seedPassword), isNull);
        expect(await auth.currentUserId(), 'u-active');
      });

      test(
        'wrong password, unknown email and unknown phone are one failure',
        () async {
          expect(
            await signIn(activeEmail, 'Wrong-pass-1'),
            isA<BadCredentials>(),
          );
          expect(
            await signIn('nobody@example.com', seedPassword),
            isA<BadCredentials>(),
          );
          expect(
            await signIn('01099999999', seedPassword),
            isA<BadCredentials>(),
          );
          expect(await auth.currentUserId(), isNull);
        },
      );

      test('locks for 5 minutes after 5 wrong passwords, then ends', () async {
        for (var i = 1; i < AuthLimits.maxPasswordFailures; i++) {
          expect(await signIn(activeEmail, 'x$i'), isA<BadCredentials>());
        }
        final fifth = await signIn(activeEmail, 'x5');
        expect(fifth, isA<LockedOut>());
        expect(
          (fifth as LockedOut).until.difference(_t0),
          AuthLimits.lockoutDuration,
        );
        // Even the right password is refused while locked.
        h.advance(const Duration(minutes: 4, seconds: 59));
        expect(await signIn(activeEmail, seedPassword), isA<LockedOut>());
        h.advance(const Duration(seconds: 1));
        expect(await signIn(activeEmail, seedPassword), isNull);
      });

      test('the same lockout for unknown email and unknown phone', () async {
        for (final id in ['ghost@example.com', '01599999999']) {
          for (var i = 1; i < AuthLimits.maxPasswordFailures; i++) {
            expect(await signIn(id, 'x$i'), isA<BadCredentials>(), reason: id);
          }
          final start = DateTime.utc(2026, 11, 16, 9);
          final locked = await signIn(id, 'x5');
          expect(locked, isA<LockedOut>(), reason: id);
          expect((locked as LockedOut).until.isAfter(start), isTrue);
          h.advance(AuthLimits.lockoutDuration);
          expect(
            await signIn(id, 'x'),
            isA<BadCredentials>(),
            reason: '$id after the lock ends',
          );
        }
      });

      test('a success resets the failure count', () async {
        for (var i = 0; i < AuthLimits.maxPasswordFailures - 1; i++) {
          await signIn(activeEmail, 'bad$i');
        }
        expect(await signIn(activeEmail, seedPassword), isNull);
        for (var i = 0; i < AuthLimits.maxPasswordFailures - 1; i++) {
          expect(await signIn(activeEmail, 'b$i'), isA<BadCredentials>());
        }
      });

      test('suspended shows only after the correct password', () async {
        expect(
          await signIn(suspendedEmail, 'Wrong-pass-1'),
          isA<BadCredentials>(),
        );
        expect(await signIn(suspendedEmail, seedPassword), isA<Suspended>());
        expect(await auth.currentUserId(), isNull);
      });

      test(
        'unconfirmed shows only after the correct password and sends a code',
        () async {
          expect(
            await signIn(unconfirmedPhone, 'Wrong-pass-1'),
            isA<BadCredentials>(),
          );
          expect(
            h.latestCode(unconfirmedEmail, CodePurpose.confirmEmail),
            isNull,
          );
          final f = await signIn(unconfirmedPhone, seedPassword);
          expect((f as NeedsConfirmation).email, unconfirmedEmail);
          final code = h.latestCode(
            unconfirmedEmail,
            CodePurpose.confirmEmail,
          )!;
          final r = await auth.confirmEmail(
            email: unconfirmedEmail,
            code: code,
          );
          expect(r.isOk, isTrue);
        },
      );
    });

    group('signOut and actAs', () {
      test('signOut clears the session', () async {
        await auth.signIn(identifier: activeEmail, password: seedPassword);
        expect((await auth.signOut()).isOk, isTrue);
        expect(await auth.currentUserId(), isNull);
      });

      test('actAs switches user and null returns to guest', () async {
        expect((await auth.actAs('u-active')).isOk, isTrue);
        expect(await auth.currentUserId(), 'u-active');
        expect((await auth.actAs(null)).isOk, isTrue);
        expect(await auth.currentUserId(), isNull);
      });
    });

    group('password reset', () {
      test(
        'unknown identifiers get the same answer and wait (SC-009)',
        () async {
          final known = await auth.requestPasswordReset(activeEmail);
          final unknown = await auth.requestPasswordReset('ghost@example.com');
          expect(known.isOk, isTrue);
          expect(unknown.isOk, isTrue);
          expect(
            unknown.valueOrThrow.resendAfter.difference(_t0),
            known.valueOrThrow.resendAfter.difference(_t0),
          );
          expect(
            _fail(await auth.requestPasswordReset(activeEmail)),
            isA<ResendTooSoon>(),
          );
          expect(
            _fail(await auth.requestPasswordReset('ghost@example.com')),
            isA<ResendTooSoon>(),
          );
          expect(
            h.latestCode('ghost@example.com', CodePurpose.resetPassword),
            isNull,
          );
        },
      );

      test('by phone sends the code to the account email', () async {
        await auth.requestPasswordReset(activePhone);
        expect(
          h.latestCode(activeEmail, CodePurpose.resetPassword),
          hasLength(6),
        );
      });

      test('replaces the password, signs in and clears a lock', () async {
        for (var i = 0; i < AuthLimits.maxPasswordFailures; i++) {
          await signIn(activeEmail, 'bad$i');
        }
        expect(await signIn(activeEmail, seedPassword), isA<LockedOut>());
        await auth.requestPasswordReset(activeEmail);
        final code = h.latestCode(activeEmail, CodePurpose.resetPassword)!;
        final r = await auth.resetPassword(
          identifier: activeEmail,
          code: code,
          newPassword: 'Brand-new-2',
        );
        expect(r.valueOrThrow.userId, 'u-active');
        expect(await auth.currentUserId(), 'u-active');
        await auth.signOut();
        // No wait for the lock: it was cleared.
        expect(await signIn(activeEmail, seedPassword), isA<BadCredentials>());
        expect(await signIn(activeEmail, 'Brand-new-2'), isNull);
      });

      test('the new password must meet the rules', () async {
        await auth.requestPasswordReset(activeEmail);
        final code = h.latestCode(activeEmail, CodePurpose.resetPassword)!;
        final f = _fail(
          await auth.resetPassword(
            identifier: activeEmail,
            code: code,
            newPassword: 'short',
          ),
        );
        expect((f as InvalidField).field, 'password');
        // The refusal did not use up the code.
        final ok = await auth.resetPassword(
          identifier: activeEmail,
          code: code,
          newPassword: 'Good-pass-3',
        );
        expect(ok.isOk, isTrue);
      });

      test('wrong, dead and expired codes', () async {
        await auth.requestPasswordReset(activeEmail);
        final code = h.latestCode(activeEmail, CodePurpose.resetPassword)!;
        final wrong = _otherThan(code);
        Future<Failure?> attempt(String c) async => _fail(
          await auth.resetPassword(
            identifier: activeEmail,
            code: c,
            newPassword: 'Good-pass-3',
          ),
        );
        for (var i = 1; i < AuthLimits.maxCodeTries; i++) {
          expect(
            (await attempt(wrong) as CodeWrong).triesLeft,
            AuthLimits.maxCodeTries - i,
          );
        }
        expect(await attempt(wrong), isA<CodeDead>());
        h.advance(AuthLimits.resendWait);
        await auth.requestPasswordReset(activeEmail);
        final fresh = h.latestCode(activeEmail, CodePurpose.resetPassword)!;
        h.advance(AuthLimits.codeLife);
        expect(await attempt(fresh), isA<CodeExpired>());
      });

      test('an unknown identifier answers like a wrong code', () async {
        final f = _fail(
          await auth.resetPassword(
            identifier: 'ghost@example.com',
            code: '123456',
            newPassword: 'Good-pass-3',
          ),
        );
        expect(f, isA<CodeWrong>());
        expect((f as CodeWrong).triesLeft, AuthLimits.maxCodeTries - 1);
      });
    });

    test('changes fires after a successful write', () async {
      var fired = 0;
      final sub = auth.changes.listen((_) => fired++);
      await auth.signIn(identifier: activeEmail, password: seedPassword);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(fired, greaterThan(0));
    });
  });
}

void main() {
  authRepositoryContract('in memory', createInMemoryHarness);
}
