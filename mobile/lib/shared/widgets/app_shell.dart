import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../extensions/context_x.dart';

/// Bottom navigation around the five main tabs. The active tab gets a gold
/// bar above its icon, as in the designs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (LucideIcons.house, l10n.navHome),
      (LucideIcons.compass, l10n.navExplore),
      (LucideIcons.landmark, l10n.navCulture),
      (LucideIcons.users, l10n.navCommunity),
      (LucideIcons.map, l10n.navGuides),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(top: BorderSide(color: context.palette.border)),
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
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavItem(
                          icon: items.elementAt(i).$1,
                          label: items.elementAt(i).$2,
                          selected: navigationShell.currentIndex == i,
                          onTap: () => navigationShell.goBranch(
                            i,
                            initialLocation: i == navigationShell.currentIndex,
                          ),
                        ),
                      ),
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
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.primary
        : context.palette.textTertiary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 3,
              decoration: BoxDecoration(
                color: selected
                    ? context.palette.accentGold
                    : context.palette.accentGold.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
