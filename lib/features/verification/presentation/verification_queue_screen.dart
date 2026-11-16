import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';
import 'package:sprint/core/a11y/focusable_tap.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/window/window_size.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/presentation/verification_providers.dart';
import 'package:sprint/features/verification/presentation/verification_request_detail.dart';
import 'package:sprint/features/verification/presentation/verification_request_screen.dart';
import 'package:sprint/features/verification/presentation/verification_texts.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

/// The Verification section: pending requests in the reviewer's scope, oldest
/// first, with type, faculty or department, waiting time and how the person
/// would be priced (FR-031, FR-032). The list and the request side by side
/// from the expanded window class, the list alone on compact and medium with
/// the request as its own route (FR-039).
class VerificationQueueScreen extends ConsumerStatefulWidget {
  const VerificationQueueScreen({this.selectedId, super.key});

  /// The request open at first (a deep link to `/verification/:id`).
  final String? selectedId;

  static const listKey = ValueKey<String>('verification-queue-list');
  static const emptyKey = ValueKey<String>('verification-queue-empty');
  static const uploadKey = ValueKey<String>('verification-queue-upload');
  static const detailPaneKey = ValueKey<String>('verification-detail-pane');

  static ValueKey<String> rowKey(String id) =>
      ValueKey<String>('verification-row-$id');

  @override
  ConsumerState<VerificationQueueScreen> createState() =>
      _VerificationQueueScreenState();
}

class _VerificationQueueScreenState
    extends ConsumerState<VerificationQueueScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedId;
  }

  @override
  void didUpdateWidget(VerificationQueueScreen old) {
    super.didUpdateWidget(old);
    if (widget.selectedId != old.selectedId) _selected = widget.selectedId;
  }

  void _open(String id, bool wide) {
    if (wide) {
      setState(() => _selected = id);
    } else {
      context.push(AppPaths.verificationDetailFor(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final wide = WindowSize.of(context).isWide;
    final margin = PlaceholderPage.margin(WindowSize.of(context));

    final list = _QueueList(
      selectedId: wide ? _selected : null,
      onOpen: (id) => _open(id, wide),
    );

    // A Wrap, so a large text size moves the button under the title.
    final header = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: SprintSpacing.space3,
      runSpacing: SprintSpacing.space3,
      children: [
        Text(l10n.verifRevQueueTitle, style: context.text.titleLg),
        SprintButton(
          key: VerificationQueueScreen.uploadKey,
          label: l10n.verifRevUpload,
          variant: SprintButtonVariant.tonal,
          size: SprintButtonSize.sm,
          icon: const SprintButtonIcon(PhosphorIconsRegular.uploadSimple),
          onPressed: () => context.push(AppPaths.verificationUpload),
        ),
      ],
    );

    if (!wide) {
      return SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(
            margin,
            SprintSpacing.space6,
            margin,
            SprintSpacing.space6,
          ),
          children: [
            header,
            const SizedBox(height: SprintSpacing.space4),
            list,
          ],
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                margin,
                SprintSpacing.space6,
                SprintSpacing.space4,
                SprintSpacing.space6,
              ),
              children: [
                header,
                const SizedBox(height: SprintSpacing.space4),
                list,
              ],
            ),
          ),
          VerticalDivider(
            width: SprintExtras.hairlineWidth,
            color: colors.line,
          ),
          Expanded(
            flex: 3,
            child: KeyedSubtree(
              key: VerificationQueueScreen.detailPaneKey,
              child: _selected == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(
                          SprintSpacing.space6,
                        ),
                        child: Text(
                          l10n.verifRevPickPrompt,
                          style: context.text.body.copyWith(
                            color: colors.inkMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : VerificationRequestDetail(
                      key: ValueKey<String>('detail-$_selected'),
                      id: _selected!,
                      embedded: true,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueList extends ConsumerWidget {
  const _QueueList({required this.selectedId, required this.onOpen});

  final String? selectedId;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final queue = ref.watch(verificationQueueProvider);
    return queue.when(
      loading: () => const Column(
        children: [
          Skeleton(height: SprintSize.controlHeight * 2),
          SizedBox(height: SprintSpacing.space3),
          Skeleton(height: SprintSize.controlHeight * 2),
        ],
      ),
      error: (_, _) => Text(l10n.signInUnexpected),
      data: (result) {
        final list = switch (result) {
          Ok(:final value) => value,
          Err() => const <Verification>[],
        };
        if (list.isEmpty) {
          return Padding(
            key: VerificationQueueScreen.emptyKey,
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: SprintSpacing.space8,
            ),
            child: Column(
              children: [
                SprintIcon(
                  PhosphorIconsRegular.checkCircle,
                  size: SprintSize.iconLg,
                  color: colors.inkMuted,
                ),
                const SizedBox(height: SprintSpacing.space3),
                Text(
                  l10n.verifRevQueueEmpty,
                  style: context.text.body.copyWith(color: colors.inkMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return Column(
          key: VerificationQueueScreen.listKey,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final v in list)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  bottom: SprintSpacing.space3,
                ),
                child: _QueueRow(
                  verification: v,
                  selected: v.id == selectedId,
                  onTap: () => onOpen(v.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QueueRow extends ConsumerWidget {
  const _QueueRow({
    required this.verification,
    required this.selected,
    required this.onTap,
  });

  final Verification verification;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final v = verification;
    final person = ref.watch(verificationPersonProvider(v.userId)).value;
    final units = ref.watch(owningUnitsProvider).value ?? const [];
    final unit = units.where((u) => u.id == v.owningUnitId).firstOrNull?.name;
    final now = ref.watch(appClockProvider).now();
    final wait = verificationWaitText(
      l10n,
      SprintFormat.of(context),
      now.difference(v.submittedAt),
    );
    final type = verificationTypeLabel(l10n, v.type);
    final name = person?.name ?? '';
    return KeyedSubtree(
      key: VerificationQueueScreen.rowKey(v.id),
      child: FocusableTap(
        label: l10n.verifRevRowSpoken(name, type, unit ?? '', wait),
        selected: selected,
        onTap: onTap,
        builder: (context, hovered) => Container(
          constraints: const BoxConstraints(
            minHeight: SprintSize.controlHeight,
          ),
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          decoration: BoxDecoration(
            color: selected || hovered ? colors.surfaceSunken : colors.surface,
            borderRadius: SprintRadius.lgBorder,
            border: Border.all(color: selected ? colors.primary : colors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.text.headline),
              const SizedBox(height: SprintSpacing.space1),
              Text(
                unit == null ? type : '$type · $unit',
                style: context.text.body,
              ),
              const SizedBox(height: SprintSpacing.space1),
              Row(
                children: [
                  SprintIcon(
                    PhosphorIconsRegular.clock,
                    size: SprintSize.iconSm,
                    color: colors.inkMuted,
                  ),
                  const SizedBox(width: SprintSpacing.space1),
                  Expanded(
                    child: Text(
                      wait,
                      style: context.text.caption.copyWith(
                        color: colors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                l10n.verifRevPricing,
                style: context.text.caption.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
