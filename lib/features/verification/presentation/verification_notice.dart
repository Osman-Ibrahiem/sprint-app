import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/notifications/domain/notification.dart' as app;
import 'package:sprint/features/verification/presentation/verification_texts.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

const _approved = 'verification.approved';
const _rejected = 'verification.rejected';

/// The latest unread approval or refusal of the person's verification, shown
/// on the account card (FR-034, US-05). It never marks anything read: the
/// notifications centre owns read state (research R5) and keeps the record
/// until the person opens it there.
class VerificationNotice extends ConsumerStatefulWidget {
  const VerificationNotice({super.key});

  static const noticeKey = ValueKey<String>('verification-notice');

  @override
  ConsumerState<VerificationNotice> createState() => _VerificationNoticeState();
}

class _VerificationNoticeState extends ConsumerState<VerificationNotice> {
  app.Notification? _shown;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = ref.read(currentSessionProvider).user?.id;
    if (userId == null) return;
    final repo = ref.read(notificationRepositoryProvider);
    final unread = [
      for (final n in await repo.list(userId))
        if ((n.type == _approved || n.type == _rejected) && n.readAt == null) n,
    ];
    if (!mounted || unread.isEmpty) return;
    setState(() => _shown = unread.first);
  }

  @override
  Widget build(BuildContext context) {
    // A decision made while the card is open shows at once.
    ref.listen(currentSessionProvider.select((s) => s.verification), (
      previous,
      next,
    ) {
      if (previous != next) _load();
    });
    final n = _shown;
    if (n == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);
    final approved = n.type == _approved;
    final expires = DateTime.tryParse(n.payload['expiresAt'] ?? '');
    final text = approved
        ? l10n.verifNoticeApproved(
            expires == null ? '' : format.dateWithYear(expires),
          )
        : l10n.verifNoticeRejected(
            verificationReasonText(l10n, n.payload['reason'] ?? ''),
          );
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: SprintSpacing.space4),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Container(
          key: VerificationNotice.noticeKey,
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
          decoration: BoxDecoration(
            color: approved ? colors.successSoft : colors.dangerSoft,
            borderRadius: SprintRadius.mdBorder,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SprintIcon(
                approved
                    ? PhosphorIconsRegular.sealCheck
                    : PhosphorIconsRegular.xCircle,
                size: SprintSize.iconMd,
                color: approved ? colors.success : colors.danger,
              ),
              const SizedBox(width: SprintSpacing.space2),
              Expanded(
                child: Text(
                  text,
                  style: context.text.body.copyWith(color: colors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
