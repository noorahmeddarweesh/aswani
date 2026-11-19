import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_settings.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/labeled_field.dart';
import '../../../../shared/widgets/selectable_option_card.dart';

/// Internal screen that shows every colour token, text style and shared
/// component, in both languages and both themes. The team compares it with
/// the designs before building real screens. Not part of the release flow.
class DesignSystemGalleryScreen extends ConsumerStatefulWidget {
  const DesignSystemGalleryScreen({super.key});

  @override
  ConsumerState<DesignSystemGalleryScreen> createState() =>
      _DesignSystemGalleryScreenState();
}

class _DesignSystemGalleryScreenState
    extends ConsumerState<DesignSystemGalleryScreen> {
  bool _optionSelected = true;
  bool _agreed = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.text;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.galleryTitle),
        actions: [
          TextButton(
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
            child: Text(l10n.switchLanguage),
          ),
          IconButton(
            tooltip: l10n.switchTheme,
            icon: const Icon(Icons.contrast),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: SafeArea(
        child: MaxWidthBox(
          child: ListView(
            padding: AppSpacing.screenPadding.copyWith(
              top: AppSpacing.md,
              bottom: AppSpacing.xxxl,
            ),
            children: [
              Text(l10n.galleryIntro, style: text.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(l10n.gallerySectionColors),
              const _Swatches(),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(l10n.gallerySectionTypography),
              Text(l10n.sampleEyebrow, style: text.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.sampleDisplay, style: text.displayLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.sampleHeadline, style: text.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.sampleSectionTitle, style: text.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.sampleCardTitle, style: text.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.sampleBody, style: text.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(l10n.gallerySectionComponents),
              LabeledField(
                label: l10n.sampleFieldLabel,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(hintText: l10n.sampleFieldHint),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SelectableOptionCard(
                icon: Icons.explore_outlined,
                title: l10n.sampleOptionTitle,
                subtitle: l10n.sampleOptionSubtitle,
                selected: _optionSelected,
                onTap: () => setState(() => _optionSelected = !_optionSelected),
              ),
              const SizedBox(height: AppSpacing.md),
              CheckboxListTile(
                value: _agreed,
                onChanged: (value) => setState(() => _agreed = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.sampleCheckbox, style: text.bodySmall),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {},
                child: Text(l10n.samplePrimaryButton),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () {},
                child: Text(l10n.sampleOutlinedButton),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () {},
                  child: Text(l10n.sampleTextButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: context.text.headlineSmall),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;
    // Token names are code identifiers, shown as-is on purpose.
    final tokens = <(String, Color)>[
      ('primary', colors.primary),
      ('secondary', colors.secondary),
      ('ink', palette.ink),
      ('highlight', palette.highlight),
      ('accentGold', palette.accentGold),
      ('accentGoldOnDark', palette.accentGoldOnDark),
      ('surface', colors.surface),
      ('surfaceMuted', palette.surfaceMuted),
      ('inputFill', palette.inputFill),
      ('selectedTint', palette.selectedTint),
      ('successTint', palette.successTint),
      ('border', palette.border),
      ('divider', palette.divider),
      ('textSecondary', palette.textSecondary),
      ('textTertiary', palette.textTertiary),
      ('error', colors.error),
      ('success', palette.success),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (name, color) in tokens)
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadii.mdAll,
                    border: Border.all(color: palette.border),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(name, style: context.text.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}
