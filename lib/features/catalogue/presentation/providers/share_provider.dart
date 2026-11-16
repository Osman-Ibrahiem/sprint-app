import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sprint/core/adaptive/web_origin.dart';
import 'package:sprint/features/catalogue/domain/facility_link.dart';

part 'share_provider.g.dart';

/// The seam tests override: the system share sheet and the clipboard (FR-024).
abstract class ShareAction {
  Future<void> share({required String text, required String url});
  Future<void> copy(String url);
}

class DefaultShareAction implements ShareAction {
  const DefaultShareAction();

  @override
  Future<void> share({required String text, required String url}) async {
    await SharePlus.instance.share(ShareParams(text: '$text\n$url'));
  }

  @override
  Future<void> copy(String url) => Clipboard.setData(ClipboardData(text: url));
}

@Riverpod(keepAlive: true)
ShareAction shareAction(Ref ref) => const DefaultShareAction();

/// The compile-time site address for sharing from outside the web build
/// (`--dart-define=SPRINT_WEB_BASE=https://host/sprint-app/`).
const _compileTimeBase = String.fromEnvironment('SPRINT_WEB_BASE');

/// The full public link of a facility: the site's own address on the web, the
/// compile-time address elsewhere, and just the path when neither is known.
/// Always built from the id, never from the name (FR-024, R7).
String shareUrlFor(String id, {String? webBase, String? configuredBase}) {
  final base = webBase ?? webBaseUrl() ?? configuredBase ?? _compileTimeBase;
  final path = FacilityLink.path(id);
  if (base.isEmpty) return path;
  final root = base.endsWith('/') ? base : '$base/';
  return '$root#$path';
}
