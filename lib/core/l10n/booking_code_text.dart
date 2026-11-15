import 'package:flutter/material.dart';
import 'package:sprint/core/fonts/deferred_fonts.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_text.g.dart';

/// A booking code in the `code` style (IBM Plex Mono), kept left-to-right
/// inside Arabic text (FR-014). Loads the mono font on first use.
class BookingCodeText extends StatefulWidget {
  const BookingCodeText(this.code, {this.color, super.key});

  final String code;
  final Color? color;

  @override
  State<BookingCodeText> createState() => _BookingCodeTextState();
}

class _BookingCodeTextState extends State<BookingCodeText> {
  @override
  void initState() {
    super.initState();
    // Repaint once the font is there; until then the fallback monospace shows.
    ensureMonoFont().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LtrIsolate(
      child: Text(
        widget.code,
        textDirection: TextDirection.ltr,
        style: SprintText.code.copyWith(
          color: widget.color ?? context.colors.ink,
        ),
      ),
    );
  }
}
