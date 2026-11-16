import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

/// "للعرض بس": a small dismissible notice on a code screen that shows the
/// newest code sent to [email] for [purpose], read from the simulated mailbox
/// (FR-023). It renders nothing when the mailbox provider is null (demo tools
/// off) or when there is no code yet, so a real build never exposes codes.
class DemoCodeNotice extends ConsumerStatefulWidget {
  const DemoCodeNotice({required this.email, required this.purpose, super.key});

  final String email;
  final CodePurpose purpose;

  static const dismissKey = ValueKey<String>('demo-code-notice-dismiss');

  @override
  ConsumerState<DemoCodeNotice> createState() => _DemoCodeNoticeState();
}

class _DemoCodeNoticeState extends ConsumerState<DemoCodeNotice> {
  StreamSubscription<void>? _sub;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    // A resend adds an email; show its code without a rebuild from outside.
    _sub = ref
        .read(simulatedMailboxProvider)
        ?.changes
        .listen((_) => mounted ? setState(() {}) : null);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mailbox = ref.watch(simulatedMailboxProvider);
    if (mailbox == null || _dismissed) return const SizedBox.shrink();
    final code = mailbox.latestCodeFor(widget.email, widget.purpose);
    if (code == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: SprintSpacing.space3,
        top: SprintSpacing.space2,
        bottom: SprintSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: colors.warningSoft,
        borderRadius: SprintRadius.mdBorder,
      ),
      child: Row(
        children: [
          SprintIcon(
            Icons.science_outlined,
            size: SprintSize.iconMd,
            color: colors.ink,
          ),
          const SizedBox(width: SprintSpacing.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.demoNoticeTitle,
                  style: context.text.caption.copyWith(color: colors.inkMuted),
                ),
                Text(
                  l10n.demoNoticeCode(ltrIsolate(code)),
                  style: context.text.label.copyWith(color: colors.ink),
                ),
              ],
            ),
          ),
          SprintButton(
            key: DemoCodeNotice.dismissKey,
            label: l10n.demoNoticeDismiss,
            variant: SprintButtonVariant.ghost,
            size: SprintButtonSize.sm,
            onPressed: () => setState(() => _dismissed = true),
          ),
        ],
      ),
    );
  }
}
