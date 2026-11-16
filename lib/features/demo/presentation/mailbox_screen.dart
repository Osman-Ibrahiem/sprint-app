import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/auth/data/simulated_mailbox.dart';
import 'package:sprint/features/auth/domain/simulated_email.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

/// "صندوق البريد التجريبي" at `/demo/mailbox`: every email the app would have
/// sent, newest first, with the code copyable (FR-023). The route exists only
/// while demo tools are on.
class MailboxScreen extends ConsumerStatefulWidget {
  const MailboxScreen({super.key});

  static const emptyKey = ValueKey<String>('mailbox-empty');

  @override
  ConsumerState<MailboxScreen> createState() => _MailboxScreenState();
}

class _MailboxScreenState extends ConsumerState<MailboxScreen> {
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
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
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final emails =
        ref.watch(simulatedMailboxProvider)?.list() ?? const <SimulatedEmail>[];
    final m = PlaceholderPage.margin(WindowSize.of(context));
    return Scaffold(
      appBar: AdaptiveAppBar(title: l10n.mailboxTitle),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: SprintSize.contentMax),
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                m,
                SprintSpacing.space4,
                m,
                SprintSpacing.space8,
              ),
              children: [
                Text(
                  l10n.mailboxNote,
                  style: context.text.body.copyWith(color: colors.inkMuted),
                ),
                const SizedBox(height: SprintSpacing.space4),
                if (emails.isEmpty)
                  Column(
                    key: MailboxScreen.emptyKey,
                    children: [
                      SprintIcon(
                        Icons.mail_outline,
                        size: SprintSize.iconLg,
                        color: colors.inkMuted,
                      ),
                      const SizedBox(height: SprintSpacing.space2),
                      Text(l10n.mailboxEmptyTitle, style: context.text.title),
                      const SizedBox(height: SprintSpacing.space1),
                      Text(
                        l10n.mailboxEmptyBody,
                        textAlign: TextAlign.center,
                        style: context.text.body.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                for (final email in emails) ...[
                  _EmailCard(email: email),
                  const SizedBox(height: SprintSpacing.space3),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailCard extends StatelessWidget {
  const _EmailCard({required this.email});

  final SimulatedEmail email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);
    final code = SimulatedMailbox.codeOf(email);
    return Container(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(email.subject, style: context.text.bodyStrong),
          const SizedBox(height: SprintSpacing.space1),
          Text(
            l10n.mailboxTo,
            style: context.text.caption.copyWith(color: colors.inkMuted),
          ),
          LtrIsolate(
            child: Text(
              email.to,
              style: context.text.label.copyWith(color: colors.ink),
            ),
          ),
          Text(
            '${format.date(email.sentAt)} · ${format.time(email.sentAt)}',
            style: context.text.caption.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: SprintSpacing.space3),
          Text(
            email.body,
            style: context.text.body.copyWith(color: colors.ink),
          ),
          if (code != null) ...[
            const SizedBox(height: SprintSpacing.space3),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SprintButton(
                label: l10n.mailboxCopyCode,
                variant: SprintButtonVariant.secondary,
                size: SprintButtonSize.sm,
                icon: const SprintButtonIcon(Icons.copy_outlined),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(ClipboardData(text: code));
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.mailboxCopied)),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
