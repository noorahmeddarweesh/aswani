import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_typography.dart';
import '../extensions/context_x.dart';

/// The ASWANI mark: an "A" in a circle and the wordmark.
/// [onDark] is used on photos (white); otherwise gold circle, navy text.
class AswaniLogo extends StatelessWidget {
  const AswaniLogo({super.key, this.onDark = false, this.size = 28});

  final bool onDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    final circle = onDark
        ? context.colors.onPrimary
        : context.palette.accentGold;
    final letter = onDark
        ? context.colors.onPrimary
        : context.palette.accentGold;
    final word = onDark ? context.colors.onPrimary : context.colors.primary;

    return Semantics(
      label: context.l10n.brandName,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: circle, width: 1.2),
            ),
            child: Text(
              'A',
              style: TextStyle(
                fontFamily: AppTypography.displayFamily,
                fontSize: size * 0.5,
                color: letter,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: size * 0.36),
          Text(
            context.l10n.brandName,
            style: context.text.titleMedium?.copyWith(
              color: word,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              fontSize: size * 0.56,
            ),
          ),
        ],
      ),
    );
  }
}
