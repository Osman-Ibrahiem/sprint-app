import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_loader.dart';
import 'package:sprint/core/adaptive/adaptive_sheet.dart';
import 'package:sprint/core/adaptive/photo_capabilities.dart';
import 'package:sprint/core/data/jpeg_encoder.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

/// Longest side of the stored ID card photo, in pixels (research R7).
const int idCardMaxSide = 1280;

/// JPEG quality of the stored ID card photo (research R7).
const int idCardJpegQuality = 80;

enum IdCardSource { camera, gallery }

/// Where the picture comes from. Injectable, so tests use a fake picker
/// instead of the platform's.
abstract interface class IdCardPhotoSource {
  /// The raw bytes of the chosen image, or null when the person backed out.
  /// Throws when the platform refuses (for example a denied permission).
  Future<Uint8List?> pick(IdCardSource source);
}

/// `image_picker`: camera on Android and iOS, gallery or files everywhere.
/// Images only; on the web and desktop it opens the file selector.
class ImagePickerIdCardSource implements IdCardPhotoSource {
  const ImagePickerIdCardSource();

  @override
  Future<Uint8List?> pick(IdCardSource source) async {
    final file = await ImagePicker().pickImage(
      source: source == IdCardSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
    );
    return file?.readAsBytes();
  }
}

final idCardPhotoSourceProvider = Provider<IdCardPhotoSource>(
  (ref) => const ImagePickerIdCardSource(),
);

/// Turns the chosen bytes into the stored picture, or null when they are not
/// an image.
typedef IdCardEncoder = Future<Uint8List?> Function(Uint8List bytes);

/// Decodes, straightens, shrinks the longest side to [idCardMaxSide] and
/// writes a JPEG at [idCardJpegQuality]. Pure, so it can run in an isolate.
Uint8List? encodeIdCardJpeg(Uint8List bytes) => encodeJpeg(
      bytes,
      maxSide: idCardMaxSide,
      quality: idCardJpegQuality,
    );

/// Runs [encodeIdCardJpeg] in a background isolate (inline on the web).
final idCardEncoderProvider = Provider<IdCardEncoder>(
  (ref) =>
      (bytes) => compute(encodeIdCardJpeg, bytes),
);

/// The ID card photo field of the verification request (FR-024, research
/// R7): choose the source, wait while the picture is prepared, see a preview
/// at [SprintExtras.idCardPreviewHeight] and replace it before sending.
class IdCardPhotoPicker extends ConsumerStatefulWidget {
  const IdCardPhotoPicker({
    required this.photo,
    required this.onChanged,
    this.error,
    this.enabled = true,
    super.key,
  });

  /// The prepared picture, or null while none is chosen.
  final Uint8List? photo;
  final ValueChanged<Uint8List> onChanged;
  final String? error;
  final bool enabled;

  static const buttonKey = ValueKey<String>('id-card-photo-button');
  static const previewKey = ValueKey<String>('id-card-photo-preview');

  @override
  ConsumerState<IdCardPhotoPicker> createState() => _IdCardPhotoPickerState();
}

class _IdCardPhotoPickerState extends ConsumerState<IdCardPhotoPicker> {
  bool _busy = false;
  String? _problem;

  Future<void> _choose() async {
    final l10n = AppLocalizations.of(context);
    IdCardSource? source = IdCardSource.gallery;
    if (cameraAvailableOf(context)) {
      source = await showSprintSheet<IdCardSource>(
        context: context,
        title: l10n.verifPhotoSourceTitle,
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
    }
    if (source == null || !mounted) return;
    setState(() {
      _busy = true;
      _problem = null;
    });
    String? problem;
    Uint8List? prepared;
    try {
      final raw = await ref.read(idCardPhotoSourceProvider).pick(source);
      if (raw != null) {
        prepared = await ref.read(idCardEncoderProvider)(raw);
        if (prepared == null && mounted) {
          problem = AppLocalizations.of(context).verifPhotoNotImage;
        }
      }
    } on Object {
      if (mounted) problem = AppLocalizations.of(context).signInUnexpected;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _problem = problem;
    });
    if (prepared != null) widget.onChanged(prepared);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final message = widget.error ?? _problem;
    final hasPhoto = widget.photo != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.verifPhotoLabel, style: context.text.label),
        const SizedBox(height: SprintSpacing.space1),
        Container(
          height: SprintExtras.idCardPreviewHeight,
          decoration: BoxDecoration(
            color: message != null ? colors.dangerSoft : colors.surfaceSunken,
            borderRadius: SprintRadius.mdBorder,
            border: Border.all(
              color: message != null ? colors.danger : colors.controlBorder,
              width: SprintExtras.hairlineWidth,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _busy
              ? Center(
                  child: AdaptiveLoader(
                    semanticLabel: l10n.verifPhotoProcessing,
                    size: SprintSize.iconLg,
                  ),
                )
              : hasPhoto
              ? Semantics(
                  image: true,
                  label: l10n.verifPhotoPreviewSpoken,
                  child: Image.memory(
                    widget.photo!,
                    key: IdCardPhotoPicker.previewKey,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Center(
                      child: SprintIcon(
                        PhosphorIconsRegular.identificationCard,
                        size: SprintSize.iconLg,
                        color: colors.inkMuted,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: SprintIcon(
                    PhosphorIconsRegular.identificationCard,
                    size: SprintSize.iconLg,
                    color: colors.inkMuted,
                  ),
                ),
        ),
        const SizedBox(height: SprintSpacing.space2),
        SprintButton(
          key: IdCardPhotoPicker.buttonKey,
          label: hasPhoto ? l10n.verifPhotoReplace : l10n.verifPhotoChoose,
          variant: SprintButtonVariant.secondary,
          onPressed: widget.enabled && !_busy ? _choose : null,
        ),
        const SizedBox(height: SprintSpacing.space1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) ...[
              SprintIcon(
                Icons.error_outline,
                size: SprintSize.iconSm,
                color: colors.danger,
              ),
              const SizedBox(width: SprintSpacing.space1),
            ],
            Expanded(
              child: Semantics(
                liveRegion: message != null,
                child: Text(
                  message ?? l10n.verifPhotoHelper,
                  style: context.text.caption.copyWith(
                    color: message != null ? colors.danger : colors.inkMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
