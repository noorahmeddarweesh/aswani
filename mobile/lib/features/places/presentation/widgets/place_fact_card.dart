import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/shared/extensions/context_x.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

/// One key fact card for a place (e.g., access type, visiting hours).
///
/// Matches the 2-column fact cards in selected_place.jpg:
/// - access -> LucideIcons.map
/// - hours -> LucideIcons.clock
class PlaceFactCard extends StatelessWidget {
  const PlaceFactCard({super.key, required this.fact});

  final PlaceFact fact;

  IconData _iconForType(String type) {
    switch (type) {
      case 'access':
        return LucideIcons.map;
      case 'hours':
        return LucideIcons.clock;
      default:
        return LucideIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final icon = _iconForType(fact.type);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.palette.link),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fact.label(lang),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
