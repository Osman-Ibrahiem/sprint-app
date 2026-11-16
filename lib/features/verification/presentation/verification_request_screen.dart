import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/option_group.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/auth/presentation/widgets/auth_form_scaffold.dart';
import 'package:sprint/features/catalogue/domain/owning_unit.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/features/verification/data/csv_sheet_parser.dart';
import 'package:sprint/features/verification/domain/national_id.dart';
import 'package:sprint/features/verification/domain/verification_state.dart';
import 'package:sprint/features/verification/presentation/id_card_photo_picker.dart';
import 'package:sprint/features/verification/presentation/verification_status_badge.dart';
import 'package:sprint/features/verification/presentation/verification_texts.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The faculties and departments a request can name (FR-024).
final owningUnitsProvider = FutureProvider.autoDispose<List<OwningUnit>>(
  (ref) => ref.watch(catalogueRepositoryProvider).listOwningUnits(),
);

enum _Field { nationalId, code, unit, photo }

/// What the person is told after sending (FR-026, US-04).
enum _Outcome { approved, pending, rejected, alreadyPending }

/// `/profile/verification`: send a verification request, or renew after it
/// expired or send a new one after a refusal (FR-024 – FR-030, BRD US-04).
/// On renewal or after a refusal the form starts from the previous answers
/// with the photo empty (FR-030). The result shows at once: approved with its
/// expiry, under review, or refused with the reason.
class VerificationRequestScreen extends ConsumerStatefulWidget {
  const VerificationRequestScreen({super.key});

  static const submitKey = ValueKey<String>('verification-submit');
  static const resultKey = ValueKey<String>('verification-result');
  static const doneKey = ValueKey<String>('verification-done');
  static const unitsKey = ValueKey<String>('verification-units');
  static const typeKey = ValueKey<String>('verification-types');

  @override
  ConsumerState<VerificationRequestScreen> createState() =>
      _VerificationRequestScreenState();
}

class _VerificationRequestScreenState
    extends ConsumerState<VerificationRequestScreen> {
  final _nationalId = TextEditingController();
  final _code = TextEditingController();
  final _focus = {for (final f in _Field.values) f: FocusNode()};
  final _errors = <_Field, String>{};
  VerificationType _type = VerificationType.student;
  String? _unitId;
  Uint8List? _photo;
  bool _loading = false;
  bool _renewal = false;
  String? _unexpected;
  _Outcome? _outcome;
  Verification? _result;

  @override
  void initState() {
    super.initState();
    // Renewal or a new request after a refusal starts from the last answers,
    // with no photo (FR-030). The national ID always starts empty: the full
    // number is not shown outside the reviewer's detail (FR-033, NFR-06).
    final previous = ref.read(currentSessionProvider).verification;
    if (previous != null && previous.status != VerificationStatus.pending) {
      _type = previous.type;
      _code.text = previous.code;
      _unitId = previous.owningUnitId;
      _renewal = previous.status == VerificationStatus.approved;
    }
  }

  @override
  void dispose() {
    _nationalId.dispose();
    _code.dispose();
    for (final n in _focus.values) {
      n.dispose();
    }
    super.dispose();
  }

  String? _check(_Field f, AppLocalizations l10n) {
    switch (f) {
      case _Field.nationalId:
        final now = ref.read(appClockProvider).now();
        return switch (validateNationalId(_nationalId.text, now: now)) {
          Invalid(:final reason) => nationalIdMessage(l10n, reason),
          _ => null,
        };
      case _Field.code:
        if (_code.text.trim().isEmpty) return l10n.verifErrCodeEmpty;
        return normalizeVerificationCode(_code.text) == null
            ? l10n.verifErrCodeInvalid
            : null;
      case _Field.unit:
        return _unitId == null ? l10n.verifErrUnitEmpty : null;
      case _Field.photo:
        return _photo == null ? l10n.verifErrPhotoEmpty : null;
    }
  }

  void _leave(_Field f) {
    final text = switch (f) {
      _Field.nationalId => _nationalId.text,
      _Field.code => _code.text,
      _ => 'x',
    };
    // Leaving an untouched field is not a mistake yet.
    if (text.isEmpty && !_errors.containsKey(f)) return;
    final message = _check(f, AppLocalizations.of(context));
    setState(() {
      if (message == null) {
        _errors.remove(f);
      } else {
        _errors[f] = message;
      }
    });
  }

  void _edited(_Field f) {
    if (_errors.containsKey(f) || _unexpected != null) {
      setState(() {
        _errors.remove(f);
        _unexpected = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    final l10n = AppLocalizations.of(context);
    final found = <_Field, String>{};
    for (final f in _Field.values) {
      final m = _check(f, l10n);
      if (m != null) found[f] = m;
    }
    if (found.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(found);
      });
      _focus[found.keys.first]!.requestFocus();
      return;
    }
    setState(() {
      _loading = true;
      _errors.clear();
      _unexpected = null;
    });
    final userId = ref.read(currentSessionProvider).user?.id;
    if (userId == null) {
      setState(() {
        _loading = false;
        _unexpected = l10n.signInUnexpected;
      });
      return;
    }
    final result = await ref
        .read(verificationRepositoryProvider)
        .submit(
          userId: userId,
          type: _type,
          nationalId: _nationalId.text,
          code: _code.text,
          owningUnitId: _unitId!,
          photo: _photo!,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Ok(:final value):
          _result = value;
          _outcome = switch (value.status) {
            VerificationStatus.approved => _Outcome.approved,
            VerificationStatus.pending => _Outcome.pending,
            VerificationStatus.rejected => _Outcome.rejected,
          };
        case Err(:final failure):
          switch (failure) {
            case StorageFull():
              // Nothing was sent: the photo could not be saved, so the form
              // stays with the reason on the photo field.
              _errors[_Field.photo] = l10n.verifStorageFull;
            case AlreadyVerified():
              _outcome = _Outcome.approved;
            case AlreadyPending():
              _outcome = _Outcome.alreadyPending;
            case InvalidField(:final field, :final reason):
              final f = switch (field) {
                'nationalId' => _Field.nationalId,
                'code' => _Field.code,
                'owningUnitId' => _Field.unit,
                'photo' => _Field.photo,
                _ => null,
              };
              final m = verificationFieldMessage(l10n, field, reason);
              if (f != null && m != null) {
                _errors[f] = m;
              } else {
                _unexpected = l10n.signInUnexpected;
              }
            default:
              _unexpected = l10n.signInUnexpected;
          }
      }
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppPaths.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(currentSessionProvider);
    final now = ref.watch(appClockProvider).now();
    final state = verificationStateOf(session.verification, now);

    if (_outcome != null) {
      return _ResultPanel(
        outcome: _outcome!,
        verification: _result,
        title: _renewal ? l10n.verifRenewTitle : l10n.verifTitle,
        onDone: _close,
      );
    }
    // One pending request at a time, and nothing to send while verified
    // (FR-027).
    if (state == VerificationState.underReview ||
        state == VerificationState.approved) {
      return _ResultPanel(
        outcome: state == VerificationState.underReview
            ? _Outcome.alreadyPending
            : _Outcome.approved,
        verification: session.verification,
        title: l10n.verifTitle,
        onDone: _close,
      );
    }

    final colors = context.colors;
    final units = ref.watch(owningUnitsProvider);

    Widget fieldError(String message) => Padding(
      padding: const EdgeInsetsDirectional.only(top: SprintSpacing.space1),
      child: Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              size: SprintSize.iconSm,
              color: colors.danger,
            ),
            const SizedBox(width: SprintSpacing.space1),
            Expanded(
              child: Text(
                message,
                style: context.text.caption.copyWith(color: colors.danger),
              ),
            ),
          ],
        ),
      ),
    );

    return AuthFormScaffold(
      title: _renewal ? l10n.verifRenewTitle : l10n.verifTitle,
      primaryLabel: _renewal ? l10n.verifActionRenew : l10n.verifSubmit,
      loading: _loading,
      onSubmit: _submit,
      footer: _unexpected == null
          ? null
          : Semantics(
              liveRegion: true,
              container: true,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: SprintSize.iconMd,
                    color: colors.danger,
                  ),
                  const SizedBox(width: SprintSpacing.space2),
                  Expanded(
                    child: Text(
                      _unexpected!,
                      style: context.text.body.copyWith(color: colors.ink),
                    ),
                  ),
                ],
              ),
            ),
      children: [
        Text(l10n.verifIntro, style: context.text.body),
        KeyedSubtree(
          key: VerificationRequestScreen.typeKey,
          child: OptionGroup<VerificationType>(
            title: l10n.verifTypeTitle,
            selected: _type,
            onSelected: _loading ? (_) {} : (t) => setState(() => _type = t),
            options: [
              for (final t in VerificationType.values)
                (t, verificationTypeLabel(l10n, t)),
            ],
          ),
        ),
        SprintTextField(
          label: l10n.verifNationalIdLabel,
          helper: l10n.verifNationalIdHelper,
          error: _errors[_Field.nationalId],
          type: SprintTextFieldType.nationalId,
          controller: _nationalId,
          focusNode: _focus[_Field.nationalId],
          enabled: !_loading,
          textInputAction: TextInputAction.next,
          onChanged: (_) => _edited(_Field.nationalId),
          onLeave: () => _leave(_Field.nationalId),
          onSubmitted: (_) => _focus[_Field.code]!.requestFocus(),
        ),
        SprintTextField(
          label: l10n.verifCodeLabel,
          helper: l10n.verifCodeHelper,
          error: _errors[_Field.code],
          controller: _code,
          focusNode: _focus[_Field.code],
          enabled: !_loading,
          textInputAction: TextInputAction.done,
          onChanged: (_) => _edited(_Field.code),
          onLeave: () => _leave(_Field.code),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            units.when(
              data: (list) => KeyedSubtree(
                key: VerificationRequestScreen.unitsKey,
                child: OptionGroup<String?>(
                  title: l10n.verifUnitTitle,
                  selected: _unitId,
                  onSelected: _loading
                      ? (_) {}
                      : (id) => setState(() {
                          _unitId = id;
                          _errors.remove(_Field.unit);
                        }),
                  options: [for (final u in list) (u.id, u.name)],
                ),
              ),
              loading: () =>
                  const Skeleton(height: SprintSize.controlHeight * 3),
              error: (_, _) => Text(l10n.signInUnexpected),
            ),
            if (_errors[_Field.unit] case final m?) fieldError(m),
          ],
        ),
        IdCardPhotoPicker(
          photo: _photo,
          enabled: !_loading,
          error: _errors[_Field.photo],
          onChanged: (bytes) => setState(() {
            _photo = bytes;
            _errors.remove(_Field.photo);
          }),
        ),
      ],
    );
  }
}

/// The result of sending, or the state of a request that already exists:
/// status word and icon, what it means, and "تمام".
class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.outcome,
    required this.verification,
    required this.title,
    required this.onDone,
  });

  final _Outcome outcome;
  final Verification? verification;
  final String title;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);
    final expires = verification?.expiresAt;
    final (state, message) = switch (outcome) {
      _Outcome.approved => (
        VerificationState.approved,
        expires == null
            ? l10n.statusVerified
            : l10n.verifResultApproved(format.dateWithYear(expires)),
      ),
      _Outcome.pending => (
        VerificationState.underReview,
        l10n.verifResultPending,
      ),
      _Outcome.alreadyPending => (
        VerificationState.underReview,
        l10n.verifAlreadyPending,
      ),
      _Outcome.rejected => (
        VerificationState.rejected,
        l10n.verifResultRejected(
          verificationReasonText(l10n, verification?.reason ?? ''),
        ),
      ),
    };
    return Scaffold(
      appBar: AdaptiveAppBar(title: title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: SprintExtras.authFormMaxWidth,
              ),
              child: Container(
                key: VerificationRequestScreen.resultKey,
                padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: SprintRadius.lgBorder,
                  border: Border.all(color: colors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: VerificationStatusBadge(state: state),
                    ),
                    const SizedBox(height: SprintSpacing.space3),
                    Semantics(
                      liveRegion: true,
                      container: true,
                      child: Text(message, style: context.text.body),
                    ),
                    const SizedBox(height: SprintSpacing.space4),
                    SprintButton(
                      key: VerificationRequestScreen.doneKey,
                      label: l10n.verifResultDone,
                      onPressed: onDone,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
