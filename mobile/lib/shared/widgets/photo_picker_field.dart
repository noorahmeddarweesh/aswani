import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/error_messages.dart';
import '../../core/network/upload.dart';
import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';

/// Opens the phone's photo picker and returns up to [max] photos, already
/// scaled down (longest side 2048 px, quality 85) so they stay under 5 MB.
typedef PickPhotos = Future<List<UploadFile>> Function(int max);

/// Replaced in tests (no real picker there).
final pickPhotosProvider = Provider<PickPhotos>((ref) => _pickWithImagePicker);

Future<List<UploadFile>> _pickWithImagePicker(int max) async {
  final picker = ImagePicker();
  final List<XFile> picked;
  if (max <= 1) {
    final one = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    picked = [?one];
  } else {
    picked = await picker.pickMultiImage(
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
      limit: max,
    );
  }
  return [
    for (final file in picked.take(max))
      UploadFile(
        name: file.name,
        bytes: await file.readAsBytes(),
        path: file.path,
      ),
  ];
}

/// Opens the camera for one photo (null when the user cancels), scaled
/// down like the picker's photos.
typedef TakePhoto = Future<UploadFile?> Function();

/// Replaced in tests (no camera there).
final takePhotoProvider = Provider<TakePhoto>((ref) => _takeWithCamera);

Future<UploadFile?> _takeWithCamera() async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.camera,
    maxWidth: 2048,
    maxHeight: 2048,
    imageQuality: 85,
  );
  if (file == null) return null;
  return UploadFile(
    name: file.name,
    bytes: await file.readAsBytes(),
    path: file.path,
  );
}

/// Photo field of the forms in the designs: a dashed box ("Add your travel
/// photos", "Add clear photos") that becomes a row of thumbnails with an
/// add tile. Rejected photos (too big, wrong type) show a message.
class PhotoPickerField extends ConsumerWidget {
  const PhotoPickerField({
    super.key,
    required this.photos,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.buttonLabel,
    this.max = UploadRules.maxPhotos,
    this.errorText,
  });

  final List<UploadFile> photos;
  final ValueChanged<List<UploadFile>> onChanged;
  final String title;
  final String? subtitle;

  /// A filled button inside the empty box (New post); none = the whole box
  /// is tappable (Contribute).
  final String? buttonLabel;
  final int max;
  final String? errorText;

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final remaining = max - photos.length;
    if (remaining <= 0) return;
    final picked = await ref.read(pickPhotosProvider)(remaining);
    if (!context.mounted || picked.isEmpty) return;
    final accepted = <UploadFile>[];
    String? rejected;
    for (final file in picked) {
      final problem = checkUpload(file);
      problem == null ? accepted.add(file) : rejected ??= problem;
    }
    if (rejected != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorFor(rejected))));
    }
    if (accepted.isNotEmpty) onChanged([...photos, ...accepted]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final error = errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (photos.isEmpty)
          _DashedBox(
            color: error == null ? palette.border : context.colors.error,
            child: InkWell(
              borderRadius: AppRadii.lgAll,
              onTap: buttonLabel == null ? () => _pick(context, ref) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.imagePlus,
                      size: 28,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.text.titleSmall,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: context.text.bodySmall,
                      ),
                    ],
                    if (buttonLabel != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          textStyle: context.text.labelLarge,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => _pick(context, ref),
                        child: Text(buttonLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length + (photos.length < max ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, i) {
                if (i == photos.length) {
                  return _AddTile(onTap: () => _pick(context, ref));
                }
                return _Thumb(
                  photo: photos[i],
                  onRemove: () => onChanged([...photos]..removeAt(i)),
                );
              },
            ),
          ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            error,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.photo, required this.onRemove});

  final UploadFile photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: AppRadii.mdAll,
            child: Image.memory(photo.bytes, fit: BoxFit.cover),
          ),
          PositionedDirectional(
            top: 4,
            end: 4,
            child: Material(
              color: context.palette.ink.withValues(alpha: 0.6),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: Tooltip(
                  message: context.l10n.photosRemove,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      LucideIcons.x,
                      size: 14,
                      color: context.palette.onBrandSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: _DashedBox(
        color: context.palette.border,
        child: InkWell(
          borderRadius: AppRadii.mdAll,
          onTap: onTap,
          child: Tooltip(
            message: context.l10n.photosAdd,
            child: Center(
              child: Icon(LucideIcons.plus, color: context.colors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded box with a dashed border, filled with the muted surface.
class _DashedBox extends StatelessWidget {
  const _DashedBox({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashPainter(color),
      child: Material(
        color: context.palette.surfaceMuted,
        borderRadius: AppRadii.lgAll,
        child: child,
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppRadii.lg),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
