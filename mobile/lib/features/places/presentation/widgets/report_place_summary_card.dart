import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/shared/extensions/context_x.dart';
import 'package:aswani/shared/widgets/app_image.dart';
import 'package:material_ui/material_ui.dart';

import '../places_strings.dart';

/// Selected Place summary card displayed in Step 2 (Report Details).
/// Matches report_details.jpg.
class ReportPlaceSummaryCard extends StatelessWidget {
  const ReportPlaceSummaryCard({
    super.key,
    required this.place,
  });

  final PlaceDetails? place;

  @override
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);
    final lang = Localizations.localeOf(context).languageCode;

    final name = place?.name(lang) ?? '';
    final location = place?.location(lang) ?? '';
    final imagePath = place?.imagePath ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: imagePath.isNotEmpty
                  ? AppImage(
                      imagePath,
                      fit: BoxFit.cover,
                    )
                  : Container(color: context.palette.surfaceMuted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.reportSelectedPlace,
                  style: context.text.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: context.palette.link,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    fontSize: 12,
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
