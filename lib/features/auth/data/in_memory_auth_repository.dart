// ignore_for_file: prefer_initializing_formals

import 'dart:math';

import 'package:clock/clock.dart';
import 'package:sprint/core/data/change_signal.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/auth/data/sign_in_throttle.dart';
import 'package:sprint/features/auth/data/simulated_mailbox.dart';
import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/domain/auth_repository.dart';
import 'package:sprint/features/auth/domain/credential.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/features/auth/domain/email_outbox.dart';
import 'package:sprint/features/auth/domain/password_hasher.dart';
import 'package:sprint/features/auth/domain/simulated_email.dart';
import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/features/identity/data/in_memory_identity_repository.dart';
import 'package:sprint/features/identity/domain/role_assignment.dart';
import 'package:sprint/features/identity/domain/user.dart';

({String subject, String body}) _plainTemplate(CodePurpose p, String code) =>
    (subject: p.name, body: code);

/// Accounts, sessions and email codes in memory, enforcing every rule in
/// contracts/repositories.md (T025). People and their roles live in
/// [identity]; this class owns credentials, codes, sign-in throttles and the
/// signed-in id. Time comes from [clock] only.
class InMemoryAuthRepository with ChangeSignal implements AuthRepository {
  InMemoryAuthRepository({
    required this.identity,
    EmailOutbox? mailbox,
    Clock? clock,
    Iterable<Credential> credentials = const [],
    Iterable<EmailCode> emailCodes = const [],
    Map<String, SignInThrottle> throttles = const {},
    Map<String, DateTime> unknownResends = const {},
    Map<String, int> unknownCodeTries = const {},
    String? currentUserId,
    Random? random,
  }) : _mailbox = mailbox ?? SimulatedMailbox(template: _plainTemplate),
       _clock = clock ?? const Clock(),
       _random = random ?? Random.secure(),
       _credentials = {for (final c in credentials) c.userId: c},
       _codes = [...emailCodes],
       _throttles = {...throttles},
       _unknownResends = {...unknownResends},
       _unknownTries = {...unknownCodeTries},
       _currentId = currentUserId;

  /// Rebuilds from [toJson] output.
  factory InMemoryAuthRepository.fromJson(
    Map<String, dynamic> json, {
    required InMemoryIdentityRepository identity,
    EmailOutbox? mailbox,
    Clock? clock,
    Random? random,
  }) => InMemoryAuthRepository(
    identity: identity,
    mailbox: mailbox,
    clock: clock,
    random: random,
    credentials: [
      for (final c in json['credentials'] as List? ?? const [])
        Credential.fromJson(c as Map<String, dynamic>),
    ],
    emailCodes: [
      for (final c in json['emailCodes'] as List? ?? const [])
        EmailCode.fromJson(c as Map<String, dynamic>),
    ],
    throttles: {
      for (final e in (json['throttles'] as Map? ?? const {}).entries)
        e.key as String: SignInThrottle.fromJson(
          e.value as Map<String, dynamic>,
        ),
    },
    unknownResends: {
      for (final e in (json['unknownResends'] as Map? ?? const {}).entries)
        e.key as String: DateTime.parse(e.value as String),
    },
    unknownCodeTries: {
      for (final e in (json['unknownCodeTries'] as Map? ?? const {}).entries)
        e.key as String: e.value as int,
    },
    currentUserId: json['currentUserId'] as String?,
  );

  final InMemoryIdentityRepository identity;
  final EmailOutbox _mailbox;
  final Clock _clock;
  final Random _random;
  final Map<String, Credential> _credentials; // by user id
  final List<EmailCode> _codes;
  final Map<String, SignInThrottle> _throttles; // by normalised identifier
  // Resend wait and wrong tries for identifiers with no account, so the
  // answers look the same as for real ones (SC-009).
  final Map<String, DateTime> _unknownResends;
  final Map<String, int> _unknownTries;
  String? _currentId; // the launch state is a guest
  int _seq = 0;

  /// The signed-in id, for the demo snapshot (FR-013).
  String? get signedInUserId => _currentId;

  /// Every credential, for the demo snapshot.
  List<Credential> get allCredentials => List.unmodifiable(_credentials.values);

  /// Everything this repository owns, for the demo snapshot. People and roles
  /// are in the identity repository's part of the snapshot.
  Map<String, dynamic> toJson() => {
    'credentials': [for (final c in _credentials.values) c.toJson()],
    'emailCodes': [for (final c in _codes) c.toJson()],
    'throttles': {for (final e in _throttles.entries) e.key: e.value.toJson()},
    'unknownResends': {
      for (final e in _unknownResends.entries) e.key: e.value.toIso8601String(),
    },
    'unknownCodeTries': {..._unknownTries},
    'currentUserId': _currentId,
  };

  // ------------------------------------------------------------- helpers

  Future<User?> _byEmail(String email) async {
    for (final u in await identity.users()) {
      if (u.email.trim().toLowerCase() == email) return u;
    }
    return null;
  }

  Future<User?> _byPhone(String phone) async {
    for (final u in await identity.users()) {
      if (normalizePhone(u.phone).valueOrNull == phone) return u;
    }
    return null;
  }

  Future<User?> _byIdentifier(String identifier) =>
      identifierKind(identifier) == IdentifierKind.email
      ? _byEmail(normalizeIdentifier(identifier))
      : _byPhone(normalizeIdentifier(identifier));

  EmailCode? _liveCode(String userId, CodePurpose purpose) {
    for (final c in _codes) {
      if (c.userId == userId && c.purpose == purpose) return c;
    }
    return null;
  }

  void _dropCode(String userId, CodePurpose purpose) =>
      _codes.removeWhere((c) => c.userId == userId && c.purpose == purpose);

  String _newCode() {
    final n = _random.nextInt(pow(10, AuthLimits.codeLength).toInt());
    return n.toString().padLeft(AuthLimits.codeLength, '0');
  }

  /// Replaces the live code and sends the email. The mailbox turns the bare
  /// code in `body` into the localised text (see `SimulatedMailbox`).
  Future<DateTime> _sendCode(User user, CodePurpose purpose) async {
    final now = _clock.now();
    final code = _newCode();
    final resendAfter = now.add(AuthLimits.resendWait);
    _dropCode(user.id, purpose);
    _codes.add(
      EmailCode(
        userId: user.id,
        purpose: purpose,
        code: code,
        expiresAt: now.add(AuthLimits.codeLife),
        resendAfter: resendAfter,
      ),
    );
    await _mailbox.send(
      SimulatedEmail(
        id: 'mail-${now.microsecondsSinceEpoch.toRadixString(36)}-${_seq++}',
        to: user.email,
        subject: '',
        body: code,
        purpose: purpose,
        sentAt: now,
      ),
    );
    return resendAfter;
  }

  /// The wait left before another code, or null when one may be sent.
  Duration? _waitFor(DateTime? resendAfter) {
    if (resendAfter == null) return null;
    final left = resendAfter.difference(_clock.now());
    return left > Duration.zero ? left : null;
  }

  /// Checks [entered] against the live code. Returns null when it matches
  /// (the code is deleted), otherwise the failure.
  Failure? _checkCode(User user, CodePurpose purpose, String entered) {
    final live = _liveCode(user.id, purpose);
    if (live == null) return const CodeExpired();
    if (live.wrongTries >= AuthLimits.maxCodeTries) return const CodeDead();
    if (!_clock.now().isBefore(live.expiresAt)) return const CodeExpired();
    if (normalizeDigits(entered) == live.code) {
      _dropCode(user.id, purpose);
      return null;
    }
    final tries = live.wrongTries + 1;
    _codes[_codes.indexOf(live)] = live.copyWith(wrongTries: tries);
    notifyChanged();
    return tries >= AuthLimits.maxCodeTries
        ? const CodeDead()
        : CodeWrong(AuthLimits.maxCodeTries - tries);
  }

  /// The key for an identifier that cannot get a [purpose] code, used for its
  /// resend wait and wrong tries.
  static String _unknownKey(CodePurpose purpose, String key) =>
      '${purpose.name}:$key';

  /// A code entered for an identifier with no live code to check: answers
  /// like a real code does, counting tries until it is dead (SC-009). A new
  /// code request for the same identifier starts the count again, as it does
  /// for a real account.
  Failure _checkUnknownCode(CodePurpose purpose, String key) {
    final k = _unknownKey(purpose, key);
    final before = _unknownTries[k] ?? 0;
    if (before >= AuthLimits.maxCodeTries) return const CodeDead();
    final tries = before + 1;
    _unknownTries[k] = tries;
    notifyChanged();
    return tries >= AuthLimits.maxCodeTries
        ? const CodeDead()
        : CodeWrong(AuthLimits.maxCodeTries - tries);
  }

  Result<T> _success<T>(T value) {
    notifyChanged();
    return Ok(value);
  }

  // ------------------------------------------------------------- session

  @override
  Future<String?> currentUserId() async =>
      await identity.getUser(_currentId ?? '') == null ? null : _currentId;

  @override
  Future<Result<Done>> actAs(String? userId) async {
    _currentId = userId;
    notifyChanged();
    return const Ok(Done());
  }

  @override
  Future<Result<Done>> signOut() => actAs(null);

  // ------------------------------------------------------------- sign up

  @override
  Future<Result<PendingConfirmation>> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final n = validateName(name);
    if (n case Invalid(:final reason)) {
      return Err(InvalidField('name', reason.name));
    }
    final p = normalizePhone(phone);
    if (p case Invalid(:final reason)) {
      return Err(InvalidField('phone', reason.name));
    }
    final e = normalizeEmail(email);
    if (e case Invalid(:final reason)) {
      return Err(InvalidField('email', reason.name));
    }
    final pw = validatePassword(password);
    if (pw case Invalid(:final reason)) {
      return Err(InvalidField('password', reason.name));
    }
    if (await _byEmail(e.valueOrNull!) != null) return const Err(EmailTaken());
    if (await _byPhone(p.valueOrNull!) != null) return const Err(PhoneTaken());

    final now = _clock.now();
    final user = User(
      id: 'user-${now.microsecondsSinceEpoch.toRadixString(36)}-${_seq++}',
      name: n.valueOrNull!,
      phone: p.valueOrNull!,
      email: e.valueOrNull!,
      createdAt: now,
      status: UserStatus.unconfirmed,
    );
    final hashed = PasswordHasher.hash(password);
    identity.addUser(user);
    _credentials[user.id] = Credential(
      userId: user.id,
      salt: hashed.salt,
      hash: hashed.hash,
    );
    await _sendCode(user, CodePurpose.confirmEmail);
    return _success(PendingConfirmation(userId: user.id, email: user.email));
  }

  @override
  Future<Result<SignedIn>> confirmEmail({
    required String email,
    required String code,
  }) async {
    final key = normalizeEmail(email).valueOrNull;
    final user = key == null ? null : await _byEmail(key);
    if (user == null || user.status != UserStatus.unconfirmed) {
      // Same answers as a real unconfirmed account, so this never tells
      // whether one exists (SC-009).
      return Err(
        _checkUnknownCode(
          CodePurpose.confirmEmail,
          key ?? email.trim().toLowerCase(),
        ),
      );
    }
    final failure = _checkCode(user, CodePurpose.confirmEmail, code);
    if (failure != null) return Err(failure);
    identity.updateUser(user.copyWith(status: UserStatus.active));
    identity.addRoleAssignment(
      RoleAssignment(
        userId: user.id,
        role: Role.booker,
        scopeType: RoleScopeType.university,
      ),
    );
    _currentId = user.id;
    return _success(SignedIn(user.id));
  }

  @override
  Future<Result<CodeSent>> resendCode({
    required String email,
    required CodePurpose purpose,
  }) async {
    final key = normalizeEmail(email).valueOrNull ?? email.trim().toLowerCase();
    final user = await _byEmail(key);
    final eligible =
        user != null &&
        (purpose == CodePurpose.confirmEmail
            ? user.status == UserStatus.unconfirmed
            : user.status == UserStatus.active);
    return _requestCode(user: eligible ? user : null, key: key, purpose);
  }

  /// Shared by resend and reset request. [user] is null for identifiers that
  /// cannot get a code; they still get the same wait and the same answer.
  Future<Result<CodeSent>> _requestCode(
    CodePurpose purpose, {
    required User? user,
    required String key,
  }) async {
    final unknownKey = _unknownKey(purpose, key);
    // Waits that have run out no longer matter; drop them so the map (and the
    // saved snapshot) does not grow with every identifier ever typed.
    final now = _clock.now();
    _unknownResends.removeWhere((_, after) => !after.isAfter(now));
    final wait = user == null
        ? _waitFor(_unknownResends[unknownKey])
        : _waitFor(_liveCode(user.id, purpose)?.resendAfter);
    if (wait != null) return Err(ResendTooSoon(wait));
    if (user == null) {
      final after = now.add(AuthLimits.resendWait);
      _unknownResends[unknownKey] = after;
      // A new "code" starts a new count of wrong tries, as for a real account.
      _unknownTries.remove(unknownKey);
      return _success(CodeSent(after));
    }
    return _success(CodeSent(await _sendCode(user, purpose)));
  }

  // ------------------------------------------------------------- sign in

  @override
  Future<Result<SignedIn>> signIn({
    required String identifier,
    required String password,
  }) async {
    final key = normalizeIdentifier(identifier);
    final now = _clock.now();
    final lockedUntil = _throttles[key]?.lockedUntil;
    if (lockedUntil != null) {
      if (now.isBefore(lockedUntil)) return Err(LockedOut(lockedUntil));
      // The lock ran out: start counting again from nothing.
      _throttles.remove(key);
    }

    final user = await _byIdentifier(identifier);
    final credential = user == null ? null : _credentials[user.id];
    // Unknown accounts do the same hashing work as known ones.
    final correct = PasswordHasher.verify(
      password,
      salt: credential?.salt ?? _dummySalt,
      hash: credential?.hash ?? _dummyHash,
    );
    if (user == null || credential == null || !correct) {
      // An entry exists only while there are failures to count.
      final throttle = _throttles.putIfAbsent(key, SignInThrottle.new);
      throttle.failures++;
      if (throttle.failures >= AuthLimits.maxPasswordFailures) {
        throttle.lockedUntil = now.add(AuthLimits.lockoutDuration);
        notifyChanged();
        return Err(LockedOut(throttle.lockedUntil!));
      }
      notifyChanged();
      return const Err(BadCredentials());
    }

    // The password was right: only now may the status show (FR-011).
    _throttles.remove(key);
    if (user.status == UserStatus.suspended) {
      notifyChanged();
      return const Err(Suspended());
    }
    if (user.status == UserStatus.unconfirmed) {
      if (_waitFor(_liveCode(user.id, CodePurpose.confirmEmail)?.resendAfter) ==
          null) {
        await _sendCode(user, CodePurpose.confirmEmail);
      }
      notifyChanged();
      return Err(NeedsConfirmation(user.email));
    }
    _currentId = user.id;
    return _success(SignedIn(user.id));
  }

  static final String _dummySalt = PasswordHasher.generateSalt();
  static final String _dummyHash = PasswordHasher.hashWithSalt(
    'dummy',
    _dummySalt,
  );

  // ------------------------------------------------------ password reset

  @override
  Future<Result<CodeSent>> requestPasswordReset(String identifier) async {
    final key = normalizeIdentifier(identifier);
    final user = await _byIdentifier(identifier);
    final eligible = user != null && user.status == UserStatus.active;
    return _requestCode(
      user: eligible ? user : null,
      key: key,
      CodePurpose.resetPassword,
    );
  }

  @override
  Future<Result<SignedIn>> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    final pw = validatePassword(newPassword);
    if (pw case Invalid(:final reason)) {
      return Err(InvalidField('password', reason.name));
    }
    final user = await _byIdentifier(identifier);
    if (user == null || user.status != UserStatus.active) {
      return Err(
        _checkUnknownCode(
          CodePurpose.resetPassword,
          normalizeIdentifier(identifier),
        ),
      );
    }
    final failure = _checkCode(user, CodePurpose.resetPassword, code);
    if (failure != null) return Err(failure);

    final hashed = PasswordHasher.hash(newPassword);
    _credentials[user.id] = Credential(
      userId: user.id,
      salt: hashed.salt,
      hash: hashed.hash,
    );
    // The lock goes for every way of signing in to this account.
    _throttles
      ..remove(normalizeIdentifier(user.email))
      ..remove(normalizeIdentifier(user.phone))
      ..remove(normalizeIdentifier(identifier));
    _currentId = user.id;
    return _success(SignedIn(user.id));
  }
}
