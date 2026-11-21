import 'package:aswani/shared/extensions/context_x.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../places_strings.dart';

/// Visiting information card banner with shield icon and unverified disclaimer.
/// Matches selected_place.jpg.
class PlaceVisitingInfoCard extends StatelessWidget {
  const PlaceVisitingInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.palette.successTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.shieldCheck, size: 20, color: context.palette.link),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.visitingInfoTitle,
                  style: context.text.titleSmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strings.visitingInfoSubtitle,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 11,
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
