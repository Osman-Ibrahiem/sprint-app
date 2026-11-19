import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/catalogue/presentation/search/search_providers.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The search field of Home and Facilities (FR-CAT-05, US-01): typing filters
/// the list at once; focusing the empty field offers the two most booked
/// facilities and the recent searches. On Home, focusing opens the Facilities
/// screen with the field focused.
class FacilitySearchField extends ConsumerStatefulWidget {
  const FacilitySearchField({this.openFacilitiesOnFocus = false, super.key});

  /// Home: a tap goes to `/facilities?focus=search`.
  final bool openFacilitiesOnFocus;

  static const mostBookedKey = ValueKey<String>('search-most-booked');
  static const recentsKey = ValueKey<String>('search-recents');
  static const clearRecentsKey = ValueKey<String>('search-clear-recents');
  static const noResultsKey = ValueKey<String>('search-no-results');

  @override
  ConsumerState<FacilitySearchField> createState() => _State();
}

class _State extends ConsumerState<FacilitySearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(searchQueryProvider),
  );
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (widget.openFacilitiesOnFocus && _focus.hasFocus) {
        _focus.unfocus();
        context.go('${AppPaths.facilities}?focus=search');
        return;
      }
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
    // `/facilities?focus=search` opens with the field focused.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.openFacilitiesOnFocus) return;
      String? focus;
      try {
        focus = GoRouterState.of(context).uri.queryParameters['focus'];
      } on Object {
        focus = null; // Shown without a router (tests, previews).
      }
      if (focus == 'search') _focus.requestFocus();
    });
  }

  bool _addressRead = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_addressRead) return;
    _addressRead = true;
    // `?q=` in the address fills the field and the filter (refresh, shared
    // links and the way back from a facility keep the search).
    final fromAddress = _addressQuery();
    if (fromAddress != null && fromAddress != _controller.text) {
      _controller.text = fromAddress;
      Future.microtask(
        () => ref.read(searchQueryProvider.notifier).set(fromAddress),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// `q` of the current address, or null when there is none or no router.
  String? _addressQuery() {
    try {
      final q = GoRouterState.of(context).uri.queryParameters['q'];
      return q == null || q.isEmpty ? null : q;
    } on Object {
      return null;
    }
  }

  /// Writes the text to `?q=` with replace, so typing never fills history.
  void _writeAddress(String value) {
    try {
      final uri = GoRouterState.of(context).uri;
      final params = {...uri.queryParameters};
      if (value.trim().isEmpty) {
        params.remove('q');
      } else {
        params['q'] = value;
      }
      context.replace(
        uri.replace(queryParameters: params.isEmpty ? null : params).toString(),
      );
    } on Object {
      // No router (tests, previews): the provider alone holds the text.
    }
  }

  Future<void> _remember(String term) =>
      ref.read(recentSearchesProvider.notifier).add(term);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(searchQueryProvider);
    final showSuggestions =
        !widget.openFacilitiesOnFocus && _focused && query.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SprintTextField(
          label: l10n.facilitiesSearchHint,
          placeholder: l10n.facilitiesSearchPlaceholder,
          showLabel: false,
          type: SprintTextFieldType.search,
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          onChanged: (v) {
            ref.read(searchQueryProvider.notifier).set(v);
            _writeAddress(v);
          },
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) _remember(v);
          },
          onClear: () {
            ref.read(searchQueryProvider.notifier).set('');
            _writeAddress('');
          },
          cancelLabel: _focused ? l10n.searchCancel : null,
          onCancel: () {
            _controller.clear();
            ref.read(searchQueryProvider.notifier).set('');
            _writeAddress('');
            _focus.unfocus();
          },
        ),
        if (showSuggestions) _Suggestions(onPick: _apply),
      ],
    );
  }

  void _apply(String term) {
    _controller.text = term;
    ref.read(searchQueryProvider.notifier).set(term);
    _remember(term);
  }
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final data = ref.watch(searchSuggestionsProvider).value;
    if (data == null) return const SizedBox.shrink();

    Widget row(String label, VoidCallback tap) => AdaptivePressable(
      label: label,
      onTap: tap,
      expand: true,
      borderRadius: SprintRadius.smBorder,
      builder: (context, _) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: SprintSize.controlHeight),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(label, style: context.text.body),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsetsDirectional.only(top: SprintSpacing.space2),
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.searchMostBooked,
            key: FacilitySearchField.mostBookedKey,
            style: context.text.label.copyWith(color: colors.inkMuted),
          ),
          for (final s in data.mostBooked)
            row(s.facility.name, () => onPick(s.facility.name)),
          if (data.recents.isNotEmpty) ...[
            const SizedBox(height: SprintSpacing.space2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.searchRecents,
                    key: FacilitySearchField.recentsKey,
                    style: context.text.label.copyWith(color: colors.inkMuted),
                  ),
                ),
                TextButton(
                  key: FacilitySearchField.clearRecentsKey,
                  onPressed: () async {
                    await ref.read(recentSearchesProvider.notifier).clear();
                  },
                  child: Text(l10n.searchClearRecents),
                ),
              ],
            ),
            for (final term in data.recents) row(term, () => onPick(term)),
          ],
        ],
      ),
    );
  }
}
