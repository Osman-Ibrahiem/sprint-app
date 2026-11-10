import 'package:flutter/widgets.dart';

/// The region that holds the active destination (capped at `content-max` on
/// large windows). Exposed so tests can measure it.
const shellContentKey = ValueKey<String>('shell-content');
