import 'package:aswani/shared/extensions/context_x.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../places_strings.dart';

/// 3-Step review progress timeline in Step 3 (Report Under Review).
/// Matches report_done.jpg.
class ReportTimelineIndicator extends StatelessWidget {
  const ReportTimelineIndicator({super.key});

  Widget _buildNode({
    required Widget child,
    required bool isFilled,
    required Color color,
  }) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isFilled ? color : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isFilled ? color : const Color(0xFFD2DCE2),
          width: 1.5,
        ),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildConnectingLine() {
    return Container(
      height: 1.5,
      color: const Color(0xFFE2EAF0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);
    final primaryColor = context.palette.ink;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Spacer(flex: 2),
            _buildNode(
              isFilled: true,
              color: primaryColor,
              child: const Icon(
                LucideIcons.check,
                size: 13,
                color: Colors.white,
              ),
            ),
            Expanded(flex: 3, child: _buildConnectingLine()),
            _buildNode(
              isFilled: true,
              color: primaryColor,
              child: const Icon(
                LucideIcons.clock,
                size: 13,
                color: Colors.white,
              ),
            ),
            Expanded(flex: 3, child: _buildConnectingLine()),
            _buildNode(
              isFilled: false,
              color: primaryColor,
              child: Icon(
                LucideIcons.star,
                size: 13,
                color: context.palette.accentGold,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          strings.reportTimelineCaption,
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(
            fontSize: 12,
            color: context.palette.textSecondary,
          ),
        ),
      ],
    );
  }
}
