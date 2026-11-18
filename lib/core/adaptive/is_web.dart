import 'package:flutter/foundation.dart' show kIsWeb;

/// True when the app runs in a browser. Screens never name a platform; this
/// lives in the adaptive layer so a widget can ask only "is the first screen
/// already an HTML page" (the splash does).
const bool runsInBrowser = kIsWeb;
