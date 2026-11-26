import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/responsive/window_size.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';
import 'motion.dart';

/// Positions of the five tabs, in bar order.
abstract final class AppTabs {
  static const int home = 0;
  static const int explore = 1;
  static const int culture = 2;
  static const int community = 3;
  static const int guides = 4;
}

/// Tapping the tab you are already on: the tab's screen scrolls back to
/// the top, as in Instagram. Holds the tab and a counter so every tap is
/// a new event.
class TabReselect extends Notifier<(int, int)> {
  @override
  (int, int) build() => (-1, 0);

  void tap(int index) => state = (index, state.$2 + 1);
}

final tabReselectProvider = NotifierProvider<TabReselect, (int, int)>(
  TabReselect.new,
);

/// Navigation around the five main tabs.
///
/// Phones: bottom bar, the active tab marked by a gold bar above its icon.
/// Tablets and landscape (600 px and wider): a side rail, marked the same way
/// on its start edge.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void select(int index) {
      final again = index == navigationShell.currentIndex;
      if (!again) Haptics.selection();
      navigationShell.goBranch(index, initialLocation: again);
      if (again) ref.read(tabReselectProvider.notifier).tap(index);
    }

    final l10n = context.l10n;
    final items = [
      (LucideIcons.house, l10n.navHome),
      (LucideIcons.compass, l10n.navExplore),
      (LucideIcons.landmark, l10n.navCulture),
      (LucideIcons.users, l10n.navCommunity),
      (LucideIcons.map, l10n.navGuides),
    ];

    List<Widget> navItems({required bool vertical}) => [
      for (var i = 0; i < items.length; i++)
        _NavItem(
          icon: items.elementAt(i).$1,
          label: items.elementAt(i).$2,
          selected: navigationShell.currentIndex == i,
          vertical: vertical,
          onTap: () => select(i),
        ),
    ];

    final border = BorderSide(color: context.palette.border);

    if (context.windowSize != WindowSize.compact) {
      return Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: BorderDirectional(end: border),
              ),
              child: SafeArea(
                right: false,
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: SizedBox(
                    width: 96,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(children: navItems(vertical: true)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: border),
        ),
        child: SafeArea(
          top: false,
          // Labels grow with the system text size, but only up to 1.3x so the
          // five tabs still fit side by side.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    for (final item in navItems(vertical: false))
                      Expanded(child: item),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.vertical,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;

  /// True in the side rail: the gold marker sits on the start edge.
  final bool vertical;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.primary
        : context.palette.textTertiary;
    final gold = context.palette.accentGold;
    final marker = AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.standard,
      width: vertical ? 3 : (selected ? 22 : 0),
      height: vertical ? (selected ? 28 : 0) : 3,
      decoration: BoxDecoration(
        color: gold,
        borderRadius: BorderRadius.circular(2),
      ),
    );
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!vertical) ...[
          SizedBox(height: 3, child: Center(child: marker)),
          const SizedBox(height: 8),
        ],
        AnimatedScale(
          scale: selected ? 1.08 : 1,
          duration: AppMotion.short,
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(
            fontSize: 11,
            color: color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: vertical
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      SizedBox(width: 3, child: Center(child: marker)),
                      Expanded(child: content),
                    ],
                  ),
                )
              : Center(child: content),
        ),
      ),
    );
  }
}
