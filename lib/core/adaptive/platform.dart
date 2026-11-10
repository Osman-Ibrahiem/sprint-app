import 'package:flutter/material.dart';

/// Platform decisions live here and in `lib/core/scroll/`, never in screens.
bool isApplePlatform(BuildContext context) {
  final p = Theme.of(context).platform;
  return p == TargetPlatform.iOS || p == TargetPlatform.macOS;
}
