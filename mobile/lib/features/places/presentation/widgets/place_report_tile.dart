import 'package:aswani/shared/extensions/context_x.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../places_strings.dart';

/// Report inaccuracy navigation tile with divider, document icon, and RTL chevron.
/// Matches selected_place.jpg.
class PlaceReportTile extends StatelessWidget {
  const PlaceReportTile({super.key, this.onReportTap});

  final VoidCallback? onReportTap;

  @override
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, thickness: 1, color: context.palette.surfaceMuted),
        const SizedBox(height: 16),
        InkWell(
          onTap: onReportTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  LucideIcons.fileText,
                  size: 18,
                  color: context.palette.link,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.reportRowText,
                    style: context.text.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.palette.link,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRightDir,
                  size: 18,
                  color: context.palette.link,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
