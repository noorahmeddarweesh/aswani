import 'package:aswani/shared/extensions/context_x.dart';
import 'package:aswani/shared/widgets/app_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../places_strings.dart';

/// Supporting photo uploader box in Step 2 (Report Details).
/// Matches report_details.jpg.
class ReportPhotoPickerBox extends StatelessWidget {
  const ReportPhotoPickerBox({
    super.key,
    this.photoPath,
    this.errorText,
    this.onTap,
    this.onRemove,
  });

  final String? photoPath;
  final String? errorText;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 88),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: context.palette.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? context.colors.error
                    : context.palette.divider,
                width: 1.5,
              ),
            ),
            child: hasPhoto
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 72,
                          width: 100,
                          child: AppImage(photoPath!, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            tooltip: strings.reportRemovePhoto,
                            padding: EdgeInsets.zero,
                            onPressed: onRemove,
                            icon: Icon(
                              LucideIcons.x,
                              size: 14,
                              color: context.palette.ink,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.imagePlus,
                          size: 22,
                          color: context.palette.link,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.reportAddPhoto,
                          style: context.text.titleSmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.palette.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.reportPhotoOptional,
                          style: context.text.bodySmall?.copyWith(
                            fontSize: 11,
                            color: context.palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: context.text.bodySmall?.copyWith(
              fontSize: 12,
              color: context.colors.error,
            ),
          ),
        ],
      ],
    );
  }
}
