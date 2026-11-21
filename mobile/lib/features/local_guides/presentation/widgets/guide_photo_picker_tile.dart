import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../local_guides_strings.dart';

/// Dashed border profile photo picker tile matching guide_application.jpg.
class GuidePhotoPickerTile extends StatelessWidget {
  const GuidePhotoPickerTile({
    super.key,
    this.photoPath,
    this.onTap,
    this.onRemove,
    this.errorText,
  });

  final String? photoPath;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: hasPhoto
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: onTap,
                      borderRadius: AppRadii.lgAll,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          borderRadius: AppRadii.lgAll,
                          border: Border.all(
                            color: errorText != null
                                ? context.colors.error
                                : context.palette.link,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: AppRadii.lgAll,
                          child: AppImage(photoPath!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    if (onRemove != null)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: context.colors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.x,
                              size: 14,
                              color: context.palette.onBrandSurface,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : CustomPaint(
                  painter: _DashedRRectPainter(
                    color: errorText != null
                        ? context.colors.error
                        : context.palette.link,
                    strokeWidth: 1.5,
                    dashLength: 5,
                    dashGap: 3,
                    borderRadius: 16,
                  ),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 90,
                      height: 54,
                      decoration: BoxDecoration(
                        color: context.palette.selectedTint,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xs,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.imagePlus,
                            size: 20,
                            color: context.palette.link,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.profilePhoto,
                            style: context.text.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: context.palette.textSecondary,
                              letterSpacing: 0,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.error,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashLength = 5.0,
    this.dashGap = 3.0,
    this.borderRadius = 16.0,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dashLength < metric.length)
            ? dashLength
            : metric.length - distance;
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashLength + dashGap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.borderRadius != borderRadius;
  }
}
