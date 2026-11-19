import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';

/// A round avatar: the photo when there is one, otherwise the first letter of
/// the name on `primary-soft` (Avatar README, FR-MYB-03). Sizes 64 and 48.
class Avatar extends StatelessWidget {
  const Avatar({
    required this.name,
    this.photo,
    this.size = SprintExtras.avatarLarge,
    super.key,
  });

  final String name;
  final Uint8List? photo;
  final double size;

  static const photoKey = ValueKey<String>('avatar-photo');
  static const initialKey = ValueKey<String>('avatar-initial');

  /// The first visible letter of [name], or "?" for an empty name.
  static String initialOf(String name) {
    final t = name.trim();
    return t.isEmpty ? '?' : String.fromCharCode(t.runes.first);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: photo != null
              ? Image.memory(
                  photo!,
                  key: photoKey,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                )
              : ColoredBox(
                  color: colors.primarySoft,
                  child: Center(
                    child: Text(
                      initialOf(name),
                      key: initialKey,
                      style:
                          (size >= SprintExtras.avatarLarge
                                  ? context.text.title
                                  : context.text.headline)
                              .copyWith(color: colors.onPrimarySoft),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
