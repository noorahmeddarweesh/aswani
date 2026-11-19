import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/network/connectivity.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../extensions/context_x.dart';

/// Slides a "You're offline" bar in at the top of every screen while the
/// phone has no network, and out again when it comes back.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Unknown (still checking) counts as online: no flash on launch.
    final offline = ref.watch(isOnlineProvider).value == false;
    final palette = context.palette;

    return Column(
      children: [
        AnimatedSize(
          duration: AppMotion.medium,
          curve: AppMotion.standard,
          child: offline
              ? Material(
                  color: palette.brandSurface,
                  child: SafeArea(
                    bottom: false,
                    child: Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.wifiOff,
                              size: 16,
                              color: palette.onBrandSurface,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                context.l10n.offlineBanner,
                                style: context.text.bodySmall?.copyWith(
                                  color: palette.onBrandSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          // The bar already covers the status bar; screens below must not
          // add it again.
          child: offline
              ? MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: child,
                )
              : child,
        ),
      ],
    );
  }
}
