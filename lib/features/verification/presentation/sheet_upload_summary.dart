import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/verification/data/csv_sheet_parser.dart';
import 'package:sprint/features/verification/domain/national_id.dart';
import 'package:sprint/features/verification/domain/sheet_batch.dart';
import 'package:sprint/features/verification/presentation/verification_texts.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The words for a row's reason code from the parser (FR-038).
String sheetReasonText(AppLocalizations l10n, String code) {
  if (code == sheetReasonColumns) return l10n.sheetReasonColumns;
  if (code == sheetReasonCode) return l10n.sheetReasonCode;
  if (code == sheetReasonType) return l10n.sheetReasonType;
  const prefix = 'nationalId.';
  if (code.startsWith(prefix)) {
    for (final p in NationalIdProblem.values) {
      if (code == '$prefix${p.name}') return nationalIdMessage(l10n, p);
    }
  }
  return l10n.sheetReasonOther;
}

/// What an upload did: rows read, added, duplicates skipped, invalid rows
/// skipped with their row number and reason, and requests approved
/// (FR-038). Never lists a national ID.
class SheetUploadSummary extends StatelessWidget {
  const SheetUploadSummary({required this.batch, super.key});

  final SheetBatch batch;

  static const summaryKey = ValueKey<String>('sheet-summary');
  static const problemsKey = ValueKey<String>('sheet-problems');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);

    Widget count(String label, int value) => Padding(
      padding: const EdgeInsetsDirectional.only(bottom: SprintSpacing.space2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.text.body)),
          Text(format.number(value), style: context.text.headline),
        ],
      ),
    );

    return Container(
      key: summaryKey,
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.checkCircle,
                size: SprintSize.iconMd,
                color: colors.success,
              ),
              const SizedBox(width: SprintSpacing.space2),
              Text(l10n.sheetSummaryTitle, style: context.text.headline),
            ],
          ),
          const SizedBox(height: SprintSpacing.space3),
          count(l10n.sheetSummaryRead, batch.rowsRead),
          count(l10n.sheetSummaryAdded, batch.rowsAdded),
          count(l10n.sheetSummaryDuplicates, batch.duplicates),
          count(l10n.sheetSummaryInvalid, batch.invalid),
          count(l10n.sheetSummaryApproved, batch.approved),
          if (batch.problems.isNotEmpty) ...[
            const SizedBox(height: SprintSpacing.space2),
            Text(l10n.sheetProblemsTitle, style: context.text.label),
            const SizedBox(height: SprintSpacing.space1),
            Column(
              key: problemsKey,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in batch.problems)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: SprintSpacing.space1,
                    ),
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
                            l10n.sheetProblemRow(
                              format.number(p.rowNumber),
                              sheetReasonText(l10n, p.reasonCode),
                            ),
                            style: context.text.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
