import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';

enum BadgeTone { gold, navy }

/// A floating icon badge around the arch photo.
class HeroBadge {
  const HeroBadge({
    required this.icon,
    required this.tone,
    required this.alignment,
    this.tilt = -0.12,
  });

  final IconData icon;

  /// Rotation in radians as in the design (negative = counter-clockwise).
  /// Mirrored automatically in right-to-left layouts.
  final double tilt;
  final BadgeTone tone;

  /// Position relative to the arch: (-1,-1) top-start ... (1,1) bottom-end.
  final AlignmentDirectional alignment;
}

/// How the caption sits on the photo.
enum CaptionStyle { onPhoto, card }

/// Arch (pages 1 and 3) or slightly tilted card (page 2).
enum HeroShape { arch, tiltedCard }

/// The arch-shaped photo with soft background shapes, floating badges and a
/// caption, used by the three onboarding pages.
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({
    super.key,
    required this.image,
    required this.caption,
    required this.captionIcon,
    this.captionStyle = CaptionStyle.onPhoto,
    this.shape = HeroShape.arch,
    this.badges = const [],
    this.sideImages = const [],
  });

  final String image;
  final String caption;
  final IconData captionIcon;
  final CaptionStyle captionStyle;
  final HeroShape shape;
  final List<HeroBadge> badges;

  /// Small tilted photos (page 3): first top-start, second bottom-end.
  final List<String> sideImages;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final archHeight = math.min(constraints.maxHeight * 0.86, 320.0);
        final archWidth = math.min(
          archHeight * 0.8,
          constraints.maxWidth * 0.66,
        );
        final archRect = Rect.fromCenter(
          center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
          width: archWidth,
          height: archHeight,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ..._backgroundShapes(context, constraints, archRect),
            Positioned.fromRect(
              rect: archRect,
              child: shape == HeroShape.tiltedCard
                  ? Transform.rotate(
                      angle: _mirror(context, 0.035),
                      child: _arch(context, archWidth),
                    )
                  : _arch(context, archWidth),
            ),
            if (sideImages.isNotEmpty)
              _sidePhoto(context, archRect, sideImages.first, top: true),
            if (sideImages.length > 1)
              _sidePhoto(
                context,
                archRect,
                sideImages.elementAt(1),
                top: false,
              ),
            for (final badge in badges) _badge(context, archRect, badge),
            if (captionStyle == CaptionStyle.card)
              _captionCard(context, archRect),
          ],
        );
      },
    );
  }

  List<Widget> _backgroundShapes(
    BuildContext context,
    BoxConstraints constraints,
    Rect arch,
  ) {
    final ring = context.palette.link;
    return [
      PositionedDirectional(
        top: -10,
        end: -30,
        child: _blob(160, context.palette.highlight.withValues(alpha: 0.18)),
      ),
      PositionedDirectional(
        bottom: -10,
        start: 10,
        child: _blob(120, context.palette.accentGold.withValues(alpha: 0.10)),
      ),
      // Thin solid ring just behind the photo.
      Positioned.fromRect(
        rect: Rect.fromCircle(center: arch.center, radius: arch.height / 2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ring.withValues(alpha: 0.35)),
          ),
        ),
      ),
      // Wider dashed gold ring.
      Positioned.fromRect(
        rect: Rect.fromCircle(center: arch.center, radius: arch.height * 0.585),
        child: CustomPaint(
          painter: _DashedCirclePainter(
            color: context.palette.accentGold.withValues(alpha: 0.4),
          ),
        ),
      ),
    ];
  }

  static double _mirror(BuildContext context, double angle) =>
      context.isRtl ? -angle : angle;

  Widget _blob(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _arch(BuildContext context, double width) {
    final radius = shape == HeroShape.arch
        ? BorderRadius.only(
            topLeft: Radius.circular(width / 2),
            topRight: Radius.circular(width / 2),
            bottomLeft: const Radius.circular(28),
            bottomRight: const Radius.circular(28),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(84),
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          );
    final onPhoto = context.colors.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: context.palette.brandSurface.withValues(alpha: 0.10),
            blurRadius: 32,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: radius - BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(image),
            if (captionStyle == CaptionStyle.onPhoto) ...[
              const PhotoScrim(strength: 0.55),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: AppSpacing.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(captionIcon, size: 14, color: onPhoto),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        caption,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall?.copyWith(
                          color: onPhoto,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, Rect arch, HeroBadge badge) {
    const size = 48.0;
    final gold = badge.tone == BadgeTone.gold;
    final dx = badge.alignment.start;
    final dy = badge.alignment.y;
    // Place the badge on the arch's edge, half outside it.
    final left = arch.center.dx + dx * (arch.width / 2) - size / 2;
    final top = arch.center.dy + dy * (arch.height / 2) * 0.86 - size / 2;
    return PositionedDirectional(
      start: left,
      top: top,
      child: Transform.rotate(
        angle: _mirror(context, badge.tilt),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: gold ? context.palette.accentGold : context.colors.primary,
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: context.colors.surface, width: 4),
            boxShadow: [
              BoxShadow(
                color: context.palette.brandSurface.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            badge.icon,
            size: 22,
            color: gold ? context.colors.primary : context.colors.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _sidePhoto(
    BuildContext context,
    Rect arch,
    String path, {
    required bool top,
  }) {
    const w = 84.0;
    const h = 104.0;
    return PositionedDirectional(
      start: top ? arch.left - w * 0.55 : arch.right - w * 0.45,
      top: top ? arch.top + arch.height * 0.12 : arch.bottom - h * 0.85,
      child: Transform.rotate(
        angle: _mirror(context, top ? -0.09 : 0.09),
        child: Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadii.lgAll,
            boxShadow: [
              BoxShadow(
                color: context.palette.brandSurface.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppImage(path, borderRadius: AppRadii.mdAll),
        ),
      ),
    );
  }

  Widget _captionCard(BuildContext context, Rect arch) {
    return PositionedDirectional(
      start: arch.left - 24,
      top: arch.bottom - 64,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: AppRadii.mdAll,
          boxShadow: [
            BoxShadow(
              color: context.palette.brandSurface.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(captionIcon, size: 16, color: context.palette.link),
            const SizedBox(height: 6),
            Text(
              caption,
              style: context.text.titleSmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// A thin dashed circle filling its box.
class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const dash = 4.0;
    const gap = 4.0;
    final count = (2 * math.pi * radius / (dash + gap)).floor();
    final step = 2 * math.pi / count;
    final sweep = step * dash / (dash + gap);
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * step, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
