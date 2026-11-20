import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/eyebrow.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/selectable_grid_card.dart';
import '../../../../shared/widgets/selectable_option_card.dart';
import '../../domain/entities/preferences.dart';
import '../viewmodels/personalization_view_model.dart';
import '../widgets/step_options.dart';
import '../widgets/step_progress.dart';
import '../../../../shared/widgets/motion.dart';

/// The 8 personalisation steps, one at a time.
class PersonalizationScreen extends ConsumerWidget {
  const PersonalizationScreen({super.key});

  /// Pops this page (Settings > Interests): first step's back, and Save.
  void _leave(BuildContext context) {
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(personalizationViewModelProvider);
    final vm = ref.read(personalizationViewModelProvider.notifier);
    final step = state.step;
    final editing = state.editing;
    ref.listen(personalizationViewModelProvider.select((s) => s.saved), (
      _,
      saved,
    ) {
      if (!saved) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.personalizationSaved)));
      _leave(context);
    });

    final titles = [
      (l10n.step1Title, l10n.step1Subtitle),
      (l10n.step2Title, l10n.step2Subtitle),
      (l10n.step3Title, l10n.step3Subtitle),
      (l10n.step4Title, l10n.step4Subtitle),
      (l10n.step5Title, l10n.step5Subtitle),
      (l10n.step6Title, l10n.step6Subtitle),
      (l10n.step7Title, l10n.step7Subtitle),
      (l10n.step8Title, l10n.step8Subtitle),
    ];
    final (title, subtitle) = titles.elementAt(step);

    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) vm.back();
      },
      child: Scaffold(
        body: SafeArea(
          child: MaxWidthBox(
            maxWidth: 640,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.xs,
                    0,
                  ),
                  child: Row(
                    children: [
                      CircleIconButton.back(
                        tooltip: l10n.back,
                        onPressed: step > 0
                            ? vm.back
                            : editing
                            ? () => _leave(context)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: StepProgress(
                          count: PersonalizationState.stepCount,
                          current: step,
                        ),
                      ),
                      TextButton(
                        onPressed: state.submitting ? null : vm.next,
                        child: Text(
                          l10n.skip,
                          style: TextStyle(color: context.palette.textTertiary),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topCenter,
                      children: [...previous, ?current],
                    ),
                    child: SingleChildScrollView(
                      key: ValueKey(step),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.lg,
                        AppSpacing.screen,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: staggered([
                          Eyebrow(
                            l10n.stepOf(
                              step + 1,
                              PersonalizationState.stepCount,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(title, style: context.text.headlineLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Text(subtitle, style: context.text.bodyMedium),
                          const SizedBox(height: AppSpacing.xl),
                          _StepAnswers(step: step, state: state, vm: vm),
                        ]),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  child: PrimaryButton(
                    label: !state.isLast
                        ? l10n.continueLabel
                        : editing
                        ? l10n.personalizationSave
                        : l10n.startExploring,
                    showArrow: true,
                    loading: state.submitting,
                    onPressed: state.hasAnswer ? vm.next : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepAnswers extends StatelessWidget {
  const _StepAnswers({
    required this.step,
    required this.state,
    required this.vm,
  });

  final int step;
  final PersonalizationState state;
  final PersonalizationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = state.preferences;

    Widget grid<T>(
      List<T> values,
      OptionView Function(T) view,
      bool Function(T) isSelected,
      void Function(T) onTap, {
      bool compact = false,
    }) {
      return _OptionGrid(
        children: [
          for (final v in values)
            Builder(
              builder: (context) {
                final o = view(v);
                return SelectableGridCard(
                  icon: o.icon,
                  title: o.title,
                  subtitle: o.subtitle,
                  compact: compact,
                  selected: isSelected(v),
                  onTap: () => onTap(v),
                );
              },
            ),
        ],
      );
    }

    return switch (step) {
      0 => Column(
        children: [
          for (final v in Persona.values) ...[
            SelectableOptionCard(
              icon: l10n.persona(v).icon,
              title: l10n.persona(v).title,
              subtitle: l10n.persona(v).subtitle,
              selected: p.persona == v,
              onTap: () => vm.selectPersona(v),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
      1 => grid(
        Purpose.values,
        l10n.purpose,
        (v) => p.purpose == v,
        vm.selectPurpose,
      ),
      2 => grid(
        StayLength.values,
        l10n.stay,
        (v) => p.stayLength == v,
        vm.selectStay,
      ),
      3 => grid(
        Interest.values,
        l10n.interest,
        p.interests.contains,
        vm.toggleInterest,
        compact: true,
      ),
      4 => grid(
        TravelStyle.values,
        l10n.style,
        p.styles.contains,
        vm.toggleStyle,
      ),
      5 => grid(
        Companions.values,
        l10n.companions,
        (v) => p.companions == v,
        vm.selectCompanions,
      ),
      6 => grid(Need.values, l10n.need, p.needs.contains, vm.toggleNeed),
      _ => Column(
        children: [
          SelectableOptionCard(
            leading: const _LanguageLetter('ع'),
            title: l10n.langArabicTitle,
            subtitle: l10n.langArabicSubtitle,
            selected: p.languageCode == 'ar',
            onTap: () => vm.selectLanguage('ar'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableOptionCard(
            leading: const _LanguageLetter('A'),
            title: l10n.langEnglishTitle,
            subtitle: l10n.langEnglishSubtitle,
            selected: p.languageCode == 'en',
            onTap: () => vm.selectLanguage('en'),
          ),
        ],
      ),
    };
  }
}

/// Two columns on phones, three on wider screens. Cards in a row share the
/// same height, whatever the text size.
class _OptionGrid extends StatelessWidget {
  const _OptionGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // One column on phones with a large system font, so words never break
    // mid-word; two on phones; three on wider screens.
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final columns = switch (context.windowSize) {
      WindowSize.compact => largeText ? 1 : 2,
      _ => largeText ? 2 : 3,
    };
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final rowChildren = children.skip(i).take(columns).toList();
      while (rowChildren.length < columns) {
        rowChildren.add(const SizedBox.shrink());
      }
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < rowChildren.length; j++) ...[
                if (j > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(child: rowChildren.elementAt(j)),
              ],
            ],
          ),
        ),
      );
      rows.add(const SizedBox(height: AppSpacing.sm));
    }
    return Column(children: rows);
  }
}

class _LanguageLetter extends StatelessWidget {
  const _LanguageLetter(this.letter);

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Text(
      letter,
      style: TextStyle(
        fontFamily: AppTypography.arabicFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: context.colors.primary,
      ),
    );
  }
}
