import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/adaptive/adaptive_sheet.dart';
import 'package:sprint/core/adaptive/photo_capabilities.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/avatar/avatar.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/identity/presentation/avatar_encoder.dart';
import 'package:sprint/features/identity/presentation/profile_photo_provider.dart';
import 'package:sprint/features/verification/presentation/id_card_photo_picker.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Edit name and photo (US-14, FR-MYB-03). Email and phone are shown locked
/// with the reason. Save is on only when something valid changed; a bad photo
/// keeps the old one.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  static const nameKey = ValueKey<String>('edit-name');
  static const saveKey = ValueKey<String>('edit-save');
  static const changePhotoKey = ValueKey<String>('edit-change-photo');
  static const removePhotoKey = ValueKey<String>('edit-remove-photo');
  static const errorKey = ValueKey<String>('edit-error');

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name = TextEditingController(
    text: ref.read(currentSessionProvider).user?.name ?? '',
  );
  Uint8List? _newPhoto;
  bool _removed = false;
  String? _photoProblem;
  bool _saving = false;
  bool _failed = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String get _trimmed => _name.text.trim();
  bool get _nameValid => _trimmed.length >= 2;

  bool _changed(String original) =>
      _trimmed != original || _newPhoto != null || _removed;

  Future<void> _choosePhoto() async {
    final l10n = AppLocalizations.of(context);
    var source = IdCardSource.gallery;
    if (cameraAvailableOf(context)) {
      final chosen = await showSprintSheet<IdCardSource>(
        context: context,
        title: l10n.editProfilePhotoSourceTitle,
        cancelLabel: l10n.verifPhotoCancel,
        actions: [
          SprintSheetAction(
            label: l10n.verifPhotoCamera,
            value: IdCardSource.camera,
          ),
          SprintSheetAction(
            label: l10n.verifPhotoGallery,
            value: IdCardSource.gallery,
          ),
        ],
      );
      if (chosen == null) return;
      source = chosen;
    }
    if (!mounted) return;
    Uint8List? prepared;
    var problem = false;
    try {
      final raw = await ref.read(idCardPhotoSourceProvider).pick(source);
      if (raw != null) {
        prepared = await ref.read(avatarEncoderProvider)(raw);
        problem = prepared == null;
      }
    } on Object {
      problem = true;
    }
    if (!mounted) return;
    setState(() {
      if (prepared != null) {
        _newPhoto = prepared;
        _removed = false;
        _photoProblem = null;
      } else if (problem) {
        _photoProblem = l10n.editProfilePhotoError;
      }
    });
  }

  Future<void> _save() async {
    final user = ref.read(currentSessionProvider).user!;
    setState(() {
      _saving = true;
      _failed = false;
    });
    String? avatarId = user.avatarId;
    var ok = true;
    if (_newPhoto != null) {
      final saved = await ref
          .read(profilePhotoStoreProvider)
          .save(user.id, _newPhoto!);
      if (saved is Ok<String>) {
        avatarId = saved.value;
      } else {
        ok = false;
      }
    }
    if (ok) {
      final r = await ref
          .read(identityRepositoryProvider)
          .updateProfile(
            user.id,
            name: _trimmed,
            avatarId: avatarId,
            clearAvatar: _removed,
          );
      ok = r is Ok;
      if (ok && _removed && user.avatarId != null) {
        await ref.read(profilePhotoStoreProvider).delete(user.avatarId!);
      }
    }
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _saving = false;
        _failed = true;
      });
      return;
    }
    await ref.read(sessionProvider.notifier).refresh();
    ref.invalidate(profilePhotoProvider(user.id));
    if (!mounted) return;
    context.canPop() ? context.pop() : context.go(AppPaths.profile);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentSessionProvider).user;
    if (user == null) return const SizedBox.shrink();
    final stored = _removed
        ? null
        : ref.watch(profilePhotoProvider(user.id)).value;
    final photo = _newPhoto ?? stored;
    final hasPhoto = photo != null;

    return Column(
      children: [
        AdaptiveAppBar(
          title: l10n.editProfileTitle,
          leading: AdaptiveBackButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(AppPaths.profile),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
            child: ListenableBuilder(
              listenable: _name,
              builder: (context, _) {
                final canSave = _nameValid && _changed(user.name) && !_saving;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Avatar(name: _trimmed, photo: photo),
                    ),
                    const SizedBox(height: SprintSpacing.space3),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: SprintSpacing.space2,
                      children: [
                        SprintButton(
                          key: EditProfileScreen.changePhotoKey,
                          label: l10n.editProfileChangePhoto,
                          variant: SprintButtonVariant.secondary,
                          onPressed: _choosePhoto,
                        ),
                        if (hasPhoto)
                          SprintButton(
                            key: EditProfileScreen.removePhotoKey,
                            label: l10n.editProfileRemovePhoto,
                            variant: SprintButtonVariant.ghost,
                            onPressed: () => setState(() {
                              _newPhoto = null;
                              _removed = true;
                            }),
                          ),
                      ],
                    ),
                    if (_photoProblem != null) ...[
                      const SizedBox(height: SprintSpacing.space2),
                      Text(
                        _photoProblem!,
                        key: EditProfileScreen.errorKey,
                        textAlign: TextAlign.center,
                        style: context.text.caption.copyWith(
                          color: context.colors.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: SprintSpacing.space5),
                    SprintTextField(
                      key: EditProfileScreen.nameKey,
                      label: l10n.editProfileName,
                      controller: _name,
                      error: _trimmed.isNotEmpty && !_nameValid
                          ? l10n.editProfileNameError
                          : null,
                    ),
                    const SizedBox(height: SprintSpacing.space4),
                    SprintTextField(
                      label: l10n.editProfileEmail,
                      type: SprintTextFieldType.email,
                      locked: true,
                      lockedValue: user.email,
                      helper: l10n.editProfileLockedHelper,
                    ),
                    const SizedBox(height: SprintSpacing.space4),
                    SprintTextField(
                      label: l10n.editProfilePhone,
                      type: SprintTextFieldType.phone,
                      locked: true,
                      lockedValue: user.phone,
                      helper: l10n.editProfileLockedHelper,
                    ),
                    if (_failed) ...[
                      const SizedBox(height: SprintSpacing.space3),
                      Text(
                        l10n.editProfileSaveError,
                        style: context.text.caption.copyWith(
                          color: context.colors.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: SprintSpacing.space6),
                    SprintButton(
                      key: EditProfileScreen.saveKey,
                      label: l10n.editProfileSave,
                      loading: _saving,
                      expand: true,
                      onPressed: canSave ? _save : null,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
