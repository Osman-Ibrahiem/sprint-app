import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';

/// Loads the bundled Cairo weights, so text measures as it does in the app.
/// Without it the test font draws every glyph one em wide (about twice
/// Cairo's Arabic), and a truncation check would cry wolf. Call it from
/// `setUpAll` in the files that check truncation.
Future<void> loadSprintFonts() async {
  final loader = FontLoader('Cairo');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/Cairo-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// The text scales every no-truncation check runs at (decision T1 of
/// refactor 000): normal, 150% and the 200% the app promises.
const truncationScales = [1.0, 1.5, 2.0];

/// The one allowed exception (decision T3 of refactor 000, 2026-11-24): an
/// app bar title may end with "…" as iOS and Android do natively, as long as
/// the full title shows in the page body ([cutTitlesMissingFromBody]) and is
/// read in full by screen readers.
const allowedTruncation = <Type>{AdaptiveAppBar, AdaptiveSliverAppBar};

bool _inside(Element element, Set<Type> types) {
  var found = false;
  element.visitAncestorElements((ancestor) {
    if (types.contains(ancestor.widget.runtimeType)) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// The cut app bar titles (allowed by T3) whose full text does not also show,
/// uncut, somewhere in the page body. Must be empty.
List<String> cutTitlesMissingFromBody(WidgetTester tester) {
  final body = <String>[];
  final cutTitles = <String>[];
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject;
    if (paragraph is! RenderParagraph || !paragraph.attached) continue;
    if (!paragraph.hasSize) continue;
    final text = paragraph.text.toPlainText();
    if (_inside(element, allowedTruncation)) {
      if (paragraph.didExceedMaxLines) cutTitles.add(text);
    } else if (!paragraph.didExceedMaxLines) {
      body.add(text);
    }
  }
  return [
    for (final title in cutTitles)
      if (!body.any((b) => b.contains(title))) title,
  ];
}

/// Every on-screen text cut short by `maxLines` (an ellipsis or a clip):
/// `RenderParagraph.didExceedMaxLines`. Overflow checks miss these, because a
/// cut text lays out without an error.
///
/// Texts inside a widget whose type is in [knownFailures] are skipped: a known
/// failure waiting for its own decision (none today; the DayStrip waited for
/// decision 18).
/// App bar titles are always skipped ([allowedTruncation], decision T3).
List<String> truncatedTexts(
  WidgetTester tester, {
  Set<Type> knownFailures = const {},
}) {
  final cut = <String>[];
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject;
    if (paragraph is! RenderParagraph || !paragraph.attached) continue;
    if (!paragraph.hasSize || !paragraph.didExceedMaxLines) continue;
    if (_inside(element, allowedTruncation)) continue;
    var known = false;
    String? owner;
    element.visitAncestorElements((ancestor) {
      final type = ancestor.widget.runtimeType;
      if (knownFailures.contains(type)) {
        known = true;
        return false;
      }
      // The nearest public widget of our own, to say where the cut text is.
      final name = type.toString();
      if (owner == null &&
          !name.startsWith('_') &&
          _ownWidget.hasMatch(name)) {
        owner = name;
      }
      return true;
    });
    if (!known) {
      final text = paragraph.text.toPlainText();
      cut.add(owner == null ? text : '$text ($owner)');
    }
  }
  return cut;
}

/// Fails when any text on screen is cut short (decision T1).
void expectNoTruncation(
  WidgetTester tester, {
  String? reason,
  Set<Type> knownFailures = const {},
}) {
  final cut = truncatedTexts(tester, knownFailures: knownFailures);
  expect(
    cut,
    isEmpty,
    reason: '${reason ?? ''} cut short: ${cut.map((t) => '"$t"').join(', ')}',
  );
}

/// Names of the app's own widgets, so a report names the component rather
/// than `Text`.
final _ownWidget = RegExp(
  r'^(Sprint\w+|Adaptive\w+|Facility\w+|Booking\w+|Slot\w+|DayStrip|'
  r'StatTile|StatusBadge|NotificationCard|NotificationBell|SettingsRow|'
  r'SegmentedControl|Avatar|WideDialog|HoldBanner|MomentPlaceholder|'
  r'CodeEntry|Gallery\w+|\w+Screen|\w+View|\w+Section|\w+Card)$',
);
