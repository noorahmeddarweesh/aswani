import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../contributions_routes.dart';
import '../viewmodels/contribute_view_model.dart';
import '../widgets/contribute_widgets.dart';

/// Step 3 of 3: what will be sent, then "Submit contribution".
class ContributePreviewScreen extends ConsumerWidget {
  const ContributePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(contributeProvider);
    final palette = context.palette;

    Widget line(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: palette.link),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: context.text.bodyMedium)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppTopBar(
        title: state.editing
            ? l10n.contributeEditTitle
            : l10n.contributePreviewTitle,
      ),
      body: MaxWidthBox(
        maxWidth: 640,
        child: ListView(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.xxs,
            bottom: AppSpacing.xxl,
          ),
          children: staggered([
            const StepBar(current: 3),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.contributePreviewBody, style: context.text.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: context.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.lgAll,
                side: BorderSide(color: palette.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.photos.isNotEmpty || state.keepPhotos.isNotEmpty)
                    SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final url in state.keepPhotos)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 2),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: AppImage(url),
                              ),
                            ),
                          for (final photo in state.photos)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 2),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.memory(
                                  photo.bytes,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.category != null)
                          Row(
                            children: [
                              Icon(
                                state.category!.icon,
                                size: 14,
                                color: palette.link,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                state.category!.label(l10n),
                                style: context.text.bodySmall?.copyWith(
                                  color: palette.link,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(state.name.trim(), style: context.text.titleLarge),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          state.description.trim(),
                          style: context.text.bodyMedium,
                        ),
                        line(LucideIcons.mapPin, state.address.trim()),
                        if (state.contact.trim().isNotEmpty)
                          line(LucideIcons.phone, state.contact.trim()),
                        if (state.photos.isEmpty && state.keepPhotos.isEmpty)
                          line(LucideIcons.imageOff, l10n.contributeNoPhotos),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              state.editing
                  ? l10n.contributeEditNote
                  : l10n.contributeReviewedNote,
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
            if (state.failure != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.errorFor(state.failure!.code),
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: state.editing
                  ? l10n.contributeEditSubmit
                  : l10n.contributeSubmit,
              loading: state.submitting,
              onPressed: () async {
                final ok = await ref.read(contributeProvider.notifier).submit();
                if (!ok || !context.mounted) return;
                // Editing goes back to Added activities (the edit page
                // closes itself); a new one shows "Contribution received".
                state.editing
                    ? context.pop()
                    : context.go(ContributeRoutes.done);
              },
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.contributeEdit),
            ),
          ]),
        ),
      ),
    );
  }
}
