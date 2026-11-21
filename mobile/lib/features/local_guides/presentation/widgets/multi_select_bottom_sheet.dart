import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../local_guides_strings.dart';

/// Modal bottom sheet for multi-selecting enum options.
class MultiSelectBottomSheet<T> extends StatefulWidget {
  const MultiSelectBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.onConfirm,
  });

  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T item) itemLabel;
  final ValueChanged<List<T>> onConfirm;

  static Future<void> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required List<T> selectedItems,
    required String Function(T item) itemLabel,
    required ValueChanged<List<T>> onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiSelectBottomSheet<T>(
        title: title,
        items: items,
        selectedItems: selectedItems,
        itemLabel: itemLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<MultiSelectBottomSheet<T>> createState() =>
      _MultiSelectBottomSheetState<T>();
}

class _MultiSelectBottomSheetState<T> extends State<MultiSelectBottomSheet<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.selectedItems);
  }

  void _toggle(T item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return Material(
      color: context.colors.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.palette.border,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: context.text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.cancel,
                    icon: Icon(
                      LucideIcons.x,
                      size: 20,
                      color: context.palette.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Options list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                itemCount: widget.items.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                ),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = _selected.contains(item);
                  final label = widget.itemLabel(item);

                  return InkWell(
                    onTap: () => _toggle(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: context.text.bodyLarge?.copyWith(
                                color: isSelected
                                    ? AppColors.riverBlue
                                    : context.palette.ink,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.riverBlue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.riverBlue
                                    : context.palette.border,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isSelected
                                ? const Icon(
                                    LucideIcons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),
            // Done button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: PrimaryButton(
                label: l10n.done,
                onPressed: () {
                  widget.onConfirm(_selected);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
