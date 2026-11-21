import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';
import 'circle_icon_button.dart';

/// The top bar of inner screens in the designs: a round back button, a
/// centred title and an optional action at the end (e.g. "Publish", "…").
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key, this.title, this.trailing, this.onBack});

  final String? title;
  final Widget? trailing;

  /// Defaults to popping the page (or going home when nothing to pop).
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: preferredSize.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              CircleIconButton.back(
                tooltip: context.l10n.back,
                onPressed:
                    onBack ??
                    () => context.canPop() ? context.pop() : context.go('/'),
              ),
              Expanded(
                child: title == null
                    ? const SizedBox.shrink()
                    : Text(
                        title!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
              // Keeps the title centred when there is no action.
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 40),
                child: trailing ?? const SizedBox(width: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
