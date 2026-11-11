import 'package:flutter/material.dart';
import 'package:sprint/core/a11y/sprint_focus_ring.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';

/// Shared behaviour of one tappable row or navigation destination: spoken label, selected
/// state, at least 48 dp, hover, keyboard focus ring and Enter/Space.
class FocusableTap extends StatefulWidget {
  const FocusableTap({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.builder,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget Function(BuildContext context, bool hovered) builder;

  @override
  State<FocusableTap> createState() => _FocusableTapState();
}

class _FocusableTapState extends State<FocusableTap> {
  bool _hovered = false;
  bool _focusVisible = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowHoverHighlight: (v) => setState(() => _hovered = v),
          onShowFocusHighlight: (v) => setState(() => _focusVisible = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onTap();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: SprintSize.controlHeight,
                minHeight: SprintSize.controlHeight,
              ),
              child: SprintFocusRing(
                visible: _focusVisible,
                borderRadius: SprintRadius.smBorder,
                child: widget.builder(context, _hovered),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
