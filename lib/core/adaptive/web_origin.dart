import 'package:flutter/foundation.dart';

/// The site's origin plus its base href on the web ("https://host/sprint-app/"),
/// or null on every other platform. The only place that asks whether the app
/// runs on the web, so sharing code never names a platform.
String? webBaseUrl() => kIsWeb ? webBaseOf(Uri.base) : null;

/// The origin plus the directory of [base]'s path:
/// `https://host/sprint-app/index.html` gives `https://host/sprint-app/`.
String webBaseOf(Uri base) {
  // Directory of the page: `/sprint-app/index.html` still gives `/sprint-app/`.
  final path = base.path.substring(0, base.path.lastIndexOf('/') + 1);
  return '${base.origin}$path';
}
