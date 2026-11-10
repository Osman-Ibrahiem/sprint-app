import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/app/app.dart';
import 'package:sprint/core/time/cairo_time.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CairoTime.ensureInitialized();
  runApp(const ProviderScope(child: SprintApp()));
}
