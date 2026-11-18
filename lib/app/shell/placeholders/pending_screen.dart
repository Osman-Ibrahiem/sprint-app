import 'package:flutter/material.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';

/// Stands in for a feature 007 screen until its task lands (removed by T079).
class PendingScreen extends StatelessWidget {
  const PendingScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) =>
      PlaceholderPage(title: title, showNote: false, blocks: 0);
}
