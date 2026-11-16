import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/verification/domain/sheet_batch.dart';
import 'package:sprint/features/verification/presentation/sheet_file_picker.dart';
import 'package:sprint/features/verification/presentation/sheet_upload_summary.dart';
import 'package:sprint/features/verification/presentation/verification_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

enum _Problem { badColumns, noValidRows, unreadable, unexpected }

/// `/verification/upload`: pick a `.csv`, send it and read what it did
/// (FR-036 – FR-038). Wrong columns or no valid rows add nothing and the
/// expected columns are explained. Earlier uploads in the reviewer's scope are
/// listed under it.
class SheetUploadScreen extends ConsumerStatefulWidget {
  const SheetUploadScreen({super.key});

  static const pickKey = ValueKey<String>('sheet-pick');
  static const helpKey = ValueKey<String>('sheet-help');
  static const errorKey = ValueKey<String>('sheet-error');
  static const batchesKey = ValueKey<String>('sheet-batches');

  @override
  ConsumerState<SheetUploadScreen> createState() => _SheetUploadScreenState();
}

class _SheetUploadScreenState extends ConsumerState<SheetUploadScreen> {
  bool _loading = false;
  SheetBatch? _batch;
  _Problem? _problem;

  Future<void> _pick() async {
    if (_loading) return;
    final reviewerId = ref.read(reviewerIdProvider);
    if (reviewerId == null) return;
    setState(() {
      _loading = true;
      _batch = null;
      _problem = null;
    });
    PickedSheet? sheet;
    try {
      sheet = await ref.read(sheetFilePickerProvider).pick();
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _problem = _Problem.unreadable;
      });
      return;
    }
    if (!mounted) return;
    if (sheet == null) {
      setState(() => _loading = false);
      return;
    }
    final result = await ref
        .read(verificationRepositoryProvider)
        .uploadSheet(reviewerId, sheet.name, sheet.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Ok(:final value):
          _batch = value;
        case Err(:final failure):
          _problem = switch (failure) {
            BadColumns() => _Problem.badColumns,
            NoValidRows() => _Problem.noValidRows,
            _ => _Problem.unexpected,
          };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final batches = ref.watch(sheetBatchesProvider);
    final format = SprintFormat.of(context);

    final problemText = switch (_problem) {
      _Problem.badColumns => l10n.sheetErrBadColumns,
      _Problem.noValidRows => l10n.sheetErrNoRows,
      _Problem.unreadable => l10n.sheetErrRead,
      _Problem.unexpected => l10n.signInUnexpected,
      null => null,
    };

    return Scaffold(
      appBar: AdaptiveAppBar(title: l10n.sheetTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: SprintExtras.authFormMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SprintIcon(
                        PhosphorIconsRegular.fileCsv,
                        size: SprintSize.iconMd,
                        color: colors.inkMuted,
                      ),
                      const SizedBox(width: SprintSpacing.space2),
                      Expanded(
                        child: Text(
                          l10n.sheetHelp,
                          key: SheetUploadScreen.helpKey,
                          style: context.text.body,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SprintSpacing.space4),
                  SprintButton(
                    key: SheetUploadScreen.pickKey,
                    label: l10n.sheetPick,
                    loading: _loading,
                    icon: const SprintButtonIcon(
                      PhosphorIconsRegular.uploadSimple,
                    ),
                    onPressed: _loading ? null : _pick,
                  ),
                  if (problemText != null) ...[
                    const SizedBox(height: SprintSpacing.space4),
                    Semantics(
                      liveRegion: true,
                      container: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SprintIcon(
                            Icons.error_outline,
                            size: SprintSize.iconMd,
                            color: colors.danger,
                          ),
                          const SizedBox(width: SprintSpacing.space2),
                          Expanded(
                            child: Text(
                              problemText,
                              key: SheetUploadScreen.errorKey,
                              style: context.text.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_batch != null) ...[
                    const SizedBox(height: SprintSpacing.space4),
                    SheetUploadSummary(batch: _batch!),
                  ],
                  const SizedBox(height: SprintSpacing.space6),
                  Text(l10n.sheetBatchesTitle, style: context.text.headline),
                  const SizedBox(height: SprintSpacing.space2),
                  batches.when(
                    loading: () =>
                        const Skeleton(height: SprintSize.controlHeight * 2),
                    error: (_, _) => Text(l10n.signInUnexpected),
                    data: (result) {
                      final list = switch (result) {
                        Ok(:final value) => value,
                        Err() => const <SheetBatch>[],
                      };
                      if (list.isEmpty) {
                        return Text(
                          l10n.sheetBatchesEmpty,
                          style: context.text.body.copyWith(
                            color: colors.inkMuted,
                          ),
                        );
                      }
                      return Column(
                        key: SheetUploadScreen.batchesKey,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final b in list)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                bottom: SprintSpacing.space2,
                              ),
                              child: Container(
                                padding: const EdgeInsetsDirectional.all(
                                  SprintSpacing.space3,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: SprintRadius.mdBorder,
                                  border: Border.all(color: colors.line),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.fileName,
                                      style: context.text.label,
                                      textDirection: TextDirection.ltr,
                                    ),
                                    Text(
                                      '${format.dateWithYear(b.uploadedAt)} · '
                                      '${format.time(b.uploadedAt)}',
                                      style: context.text.caption.copyWith(
                                        color: colors.inkMuted,
                                      ),
                                    ),
                                    Text(
                                      l10n.sheetBatchLine(
                                        b.rowsAdded,
                                        b.approved,
                                        b.duplicates + b.invalid,
                                      ),
                                      style: context.text.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
