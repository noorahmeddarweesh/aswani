import 'dart:math' as math;

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../domain/entities/post.dart';

/// The story circles at the top of Community: "Share your moment" first,
/// then one circle per highlight, which opens its stories full screen.
class HighlightsRow extends StatelessWidget {
  const HighlightsRow({
    super.key,
    required this.highlights,
    required this.onOpen,
    required this.onNewMoment,
  });

  final List<Highlight> highlights;
  final ValueChanged<Highlight> onOpen;
  final VoidCallback onNewMoment;

  static const double circle = 64;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    // One-line labels: large text grows them a little, never off the row.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SizedBox(
        height: circle + 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          children: [
            _Bubble(
              label: context.l10n.communityYourMoment,
              onTap: onNewMoment,
              ring: _DashedRing(color: context.palette.link),
              child: Icon(
                LucideIcons.plus,
                size: 26,
                color: context.palette.link,
              ),
            ),
            for (final h in highlights)
              _Bubble(
                label: h.title(lang),
                onTap: () => onOpen(h),
                ring: _SolidRing(color: context.palette.accentGold),
                child: ClipOval(child: AppImage(h.coverImage)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.label,
    required this.onTap,
    required this.ring,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final CustomPainter ring;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: AppRadii.mdAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SizedBox(
            width: HighlightsRow.circle + 16,
            child: Column(
              children: [
                CustomPaint(
                  painter: ring,
                  child: SizedBox.square(
                    dimension: HighlightsRow.circle,
                    // White gap between the ring and the photo.
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Center(child: child),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 11,
                    letterSpacing: 0,
                    color: context.palette.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin gold ring of a story circle.
class _SolidRing extends CustomPainter {
  const _SolidRing({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2 - 1,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SolidRing old) => old.color != color;
}

/// Dashed ring of "Share your moment".
class _DashedRing extends CustomPainter {
  const _DashedRing({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2 - 1;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const dashes = 30;
    const sweep = 2 * math.pi / dashes;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.5, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRing old) => old.color != color;
}
