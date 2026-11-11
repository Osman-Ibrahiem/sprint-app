import 'package:flutter/widgets.dart';

/// Left-to-right isolate for booking codes, phone numbers and emails inside
/// Arabic text (FR-014).
class LtrIsolate extends StatelessWidget {
  const LtrIsolate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Directionality(textDirection: TextDirection.ltr, child: child);
}

/// Wraps a string in Unicode LRI/PDI so it keeps its order when embedded in
/// right-to-left text (for example inside a longer Arabic sentence).
String ltrIsolate(String text) => '\u2066$text\u2069';
