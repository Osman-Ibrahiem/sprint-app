import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';

/// The frame every auth form shares (contracts/ui.md, FR-047): an adaptive
/// app bar, a centred column capped at [SprintExtras.authFormMaxWidth], an
/// [AutofillGroup], fields in reading order, and one primary button.
///
/// Fields passed in [children] should use `textInputAction: next` except the
/// last, which uses `done` and calls [onSubmit] from its `onSubmitted`, so
/// Enter submits from the keyboard.
class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    required this.title,
    required this.children,
    required this.primaryLabel,
    required this.onSubmit,
    this.loading = false,
    this.leading,
    this.footer,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final String primaryLabel;

  /// Null disables the primary button (for example while the form is empty).
  final VoidCallback? onSubmit;
  final bool loading;
  final Widget? leading;

  /// Secondary links under the primary button (switch to sign up, forgot...).
  final Widget? footer;

  static const columnKey = ValueKey<String>('auth-form-column');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdaptiveAppBar(title: title, leading: leading),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
          child: Center(
            child: ConstrainedBox(
              key: columnKey,
              constraints: const BoxConstraints(
                maxWidth: SprintExtras.authFormMaxWidth,
              ),
              child: FocusTraversalGroup(
                policy: ReadingOrderTraversalPolicy(),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        if (i > 0) const SizedBox(height: SprintSpacing.space4),
                        children[i],
                      ],
                      const SizedBox(height: SprintSpacing.space6),
                      SprintButton(
                        label: primaryLabel,
                        loading: loading,
                        onPressed: onSubmit,
                      ),
                      if (footer != null) ...[
                        const SizedBox(height: SprintSpacing.space4),
                        footer!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
