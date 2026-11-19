import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../domain/entities/place.dart';

/// One row of "Popular places": photo, category, name, city, save button.
class PlaceListTile extends StatelessWidget {
  const PlaceListTile({
    super.key,
    required this.place,
    required this.onBookmark,
    this.onTap,
  });

  final Place place;
  final VoidCallback onBookmark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.lgAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              height: 72,
              child: AppImage(place.imagePath, borderRadius: AppRadii.lgAll),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.label(lang),
                    style: context.text.bodySmall?.copyWith(
                      color: context.palette.link,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.name(lang),
                    style: context.text.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 13,
                        color: context.palette.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(place.city(lang), style: context.text.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: place.isBookmarked
                  ? l10n.bookmarkRemove
                  : l10n.bookmarkAdd,
              onPressed: onBookmark,
              icon: Icon(LucideIcons.bookmark, color: context.colors.primary),
              isSelected: place.isBookmarked,
              selectedIcon: Icon(Icons.bookmark, color: context.colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
