import 'package:flutter/foundation.dart';

/// The site's origin plus its base href on the web ("https://host/sprint-app/"),
/// or null on every other platform. The only place that asks whether the app
/// runs on the web, so sharing code never names a platform.
String? webBaseUrl() {
  if (!kIsWeb) return null;
  final base = Uri.base;
  final path = base.path.endsWith('/') ? base.path : '${base.path}/';
  return '${base.origin}$path';
}
