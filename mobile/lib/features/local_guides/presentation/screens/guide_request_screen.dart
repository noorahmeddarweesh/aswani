import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/guide_enums.dart';
import '../../domain/entities/guide_request.dart';
import '../local_guides_strings.dart';
import '../viewmodels/guide_request_form_state.dart';
import '../viewmodels/guide_request_view_model.dart';
import '../widgets/guide_duration_choice_card.dart';

/// Request a Guide Form screen matching requesting_a_guide.jpg:
/// - Top bar: back button + centered "Request a guide" title.
/// - Intro description: "Tell us what fits your plans. Choose exactly how long you need."
/// - Preferred date selector with Cairo time validation.
/// - 2-column duration grid: A few hours, One day, Two days, 3 days, Custom.
/// - Side-by-side Start time and Group size inputs.
/// - Preferred language selector.
/// - Additional notes textarea.
/// - Pinned bottom CTA: "Review request".
class GuideRequestScreen extends ConsumerStatefulWidget {
  const GuideRequestScreen({
    super.key,
    required this.guideId,
    this.onReviewPressed,
    this.onBackPressed,
  });

  final String guideId;
  final ValueChanged<GuideRequestCreate>? onReviewPressed;
  final VoidCallback? onBackPressed;

  @override
  ConsumerState<GuideRequestScreen> createState() => _GuideRequestScreenState();
}

class _GuideRequestScreenState extends ConsumerState<GuideRequestScreen> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _pickDate(GuideRequestFormState state) async {
    final cairoNow = getCairoDateTime();
    final cairoToday = DateTime(cairoNow.year, cairoNow.month, cairoNow.day);

    DateTime initialDate = cairoToday;
    if (state.date != null) {
      final parsed = DateTime.tryParse(state.date!);
      if (parsed != null && !parsed.isBefore(cairoToday)) {
        initialDate = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: cairoToday,
      lastDate: cairoToday.add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      ref
          .read(guideRequestViewModelProvider(widget.guideId).notifier)
          .setDate('$y-$m-$d');
    }
  }

  Future<void> _pickStartTime(GuideRequestFormState state) async {
    final parts = state.startTime.split(':');
    final initialHour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
    final initialMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null && mounted) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      ref
          .read(guideRequestViewModelProvider(widget.guideId).notifier)
          .setStartTime('$h:$m');
    }
  }

  void _showGroupSizePicker(GuideRequestFormState state) {
    final l10n = context.guidesL10n;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.requestGroupSize,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: List.generate(20, (index) {
                    final size = index + 1;
                    final isSelected = size == state.groupSize;
                    return InkWell(
                      onTap: () {
                        ref
                            .read(guideRequestViewModelProvider(widget.guideId)
                                .notifier)
                            .setGroupSize(size);
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: AppRadii.smAll,
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.palette.selectedTint
                              : context.palette.inputFill,
                          borderRadius: AppRadii.smAll,
                          border: Border.all(
                            color: isSelected
                                ? context.palette.selectedBorder
                                : context.palette.border,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Text(
                          '$size',
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: context.palette.ink,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(GuideRequestFormState state) {
    final l10n = context.guidesL10n;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screen,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.requestPreferredLanguage,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...GuideLanguage.values.map((lang) {
                  final isSelected = lang == state.language;
                  return ListTile(
                    title: Text(
                      l10n.languageLabel(lang),
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: context.palette.ink,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            LucideIcons.check,
                            color: context.palette.selectedBorder,
                            size: 18,
                          )
                        : null,
                    onTap: () {
                      ref
                          .read(guideRequestViewModelProvider(widget.guideId)
                              .notifier)
                          .setLanguage(lang);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSubmit() {
    final viewModel =
        ref.read(guideRequestViewModelProvider(widget.guideId).notifier);
    final isValid = viewModel.validate();
    if (isValid) {
      final state =
          ref.read(guideRequestViewModelProvider(widget.guideId));
      final payload = state.toCreatePayload();
      widget.onReviewPressed?.call(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;
    final state =
        ref.watch(guideRequestViewModelProvider(widget.guideId));
    final viewModel =
        ref.read(guideRequestViewModelProvider(widget.guideId).notifier);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  CircleIconButton.back(
                    tooltip: l10n.back,
                    onPressed: _handleBack,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.requestScreenTitle,
                        style: context.text.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.palette.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balances the 40dp back button
                ],
              ),
            ),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intro Copy
                    Text(
                      l10n.requestIntro,
                      style: context.text.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: context.palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Field 1: Preferred Date
                    Text(
                      l10n.requestPreferredDate,
                      style: context.text.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    InkWell(
                      key: const Key('request_date_picker_tile'),
                      onTap: () => _pickDate(state),
                      borderRadius: AppRadii.mdAll,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: context.palette.inputFill,
                          borderRadius: AppRadii.mdAll,
                          border: Border.all(
                            color: state.dateError != null
                                ? context.colors.error
                                : context.palette.border,
                            width: state.dateError != null ? 1.5 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 18,
                              color: context.palette.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              state.date ?? l10n.requestSelectDate,
                              style: context.text.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: state.date != null
                                    ? context.palette.ink
                                    : context.palette.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (state.dateError != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        state.dateError == 'DATE_IN_PAST'
                            ? l10n.requestDateInPast
                            : l10n.requestDateRequired,
                        key: const Key('request_date_error_text'),
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),

                    // Field 2: Tour Duration Grid
                    Text(
                      l10n.requestTourDuration,
                      style: context.text.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: GuideDurationChoiceCard(
                            key: const Key('duration_few_hours'),
                            duration: RequestDuration.fewHours,
                            isSelected:
                                state.duration == RequestDuration.fewHours,
                            onTap: () =>
                                viewModel.setDuration(RequestDuration.fewHours),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: GuideDurationChoiceCard(
                            key: const Key('duration_one_day'),
                            duration: RequestDuration.oneDay,
                            isSelected:
                                state.duration == RequestDuration.oneDay,
                            onTap: () =>
                                viewModel.setDuration(RequestDuration.oneDay),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: GuideDurationChoiceCard(
                            key: const Key('duration_two_days'),
                            duration: RequestDuration.twoDays,
                            isSelected:
                                state.duration == RequestDuration.twoDays,
                            onTap: () =>
                                viewModel.setDuration(RequestDuration.twoDays),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: GuideDurationChoiceCard(
                            key: const Key('duration_three_days'),
                            duration: RequestDuration.threeDays,
                            isSelected:
                                state.duration == RequestDuration.threeDays,
                            onTap: () => viewModel
                                .setDuration(RequestDuration.threeDays),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: GuideDurationChoiceCard(
                            key: const Key('duration_custom'),
                            duration: RequestDuration.custom,
                            isSelected:
                                state.duration == RequestDuration.custom,
                            onTap: () =>
                                viewModel.setDuration(RequestDuration.custom),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),

                    // Custom hours stepper when Custom is selected
                    if (state.duration == RequestDuration.custom) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: context.palette.surfaceMuted,
                          borderRadius: AppRadii.mdAll,
                          border: Border.all(
                            color: state.customHoursError != null
                                ? context.colors.error
                                : context.palette.border,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.requestCustomDurationLabel,
                                style: context.text.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.palette.ink,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    key: const Key('custom_hours_decrement'),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(LucideIcons.minus, size: 18),
                                    onPressed: (state.durationHours ?? 4) > 1
                                        ? () => viewModel.setCustomHours(
                                              (state.durationHours ?? 4) - 1,
                                            )
                                        : null,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: AppSpacing.xxs,
                                  ),
                                  child: Text(
                                    l10n.requestHoursCount(
                                      state.durationHours ?? 4,
                                    ),
                                    key: const Key('custom_hours_value'),
                                    style: context.text.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.palette.ink,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    key: const Key('custom_hours_increment'),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(LucideIcons.plus, size: 18),
                                    onPressed: (state.durationHours ?? 4) < 12
                                        ? () => viewModel.setCustomHours(
                                              (state.durationHours ?? 4) + 1,
                                            )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (state.customHoursError != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          l10n.requestCustomHoursRequired,
                          key: const Key('request_custom_hours_error_text'),
                          style: context.text.bodySmall?.copyWith(
                            color: context.colors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: AppSpacing.lg),

                    // Side-by-side Start time & Group size
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Start Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.requestStartTime,
                                style: context.text.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.palette.ink,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              InkWell(
                                key: const Key('request_start_time_tile'),
                                onTap: () => _pickStartTime(state),
                                borderRadius: AppRadii.mdAll,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: context.palette.inputFill,
                                    borderRadius: AppRadii.mdAll,
                                    border: Border.all(
                                      color: context.palette.border,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        LucideIcons.clock,
                                        size: 18,
                                        color: context.palette.textSecondary,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        state.startTime,
                                        style:
                                            context.text.bodyMedium?.copyWith(
                                          fontSize: 14,
                                          color: context.palette.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),

                        // Right Column: Group Size
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.requestGroupSize,
                                style: context.text.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.palette.ink,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              InkWell(
                                key: const Key('request_group_size_tile'),
                                onTap: () => _showGroupSizePicker(state),
                                borderRadius: AppRadii.mdAll,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: context.palette.inputFill,
                                    borderRadius: AppRadii.mdAll,
                                    border: Border.all(
                                      color: context.palette.border,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        LucideIcons.users,
                                        size: 18,
                                        color: context.palette.textSecondary,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          l10n.requestGroupSizeFormatted(
                                            state.groupSize,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              context.text.bodyMedium?.copyWith(
                                            fontSize: 14,
                                            color: context.palette.ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Field 3: Preferred Language
                    Text(
                      l10n.requestPreferredLanguage,
                      style: context.text.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    InkWell(
                      key: const Key('request_language_tile'),
                      onTap: () => _showLanguagePicker(state),
                      borderRadius: AppRadii.mdAll,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: context.palette.inputFill,
                          borderRadius: AppRadii.mdAll,
                          border: Border.all(color: context.palette.border),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.languageLabel(state.language),
                              style: context.text.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: context.palette.ink,
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronDown,
                              size: 18,
                              color: context.palette.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Field 4: Additional Notes (optional)
                    Text(
                      l10n.requestAdditionalNotes,
                      style: context.text.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      key: const Key('request_notes_field'),
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      onChanged: viewModel.setNotes,
                      decoration: InputDecoration(
                        hintText: l10n.requestNotesHint,
                        hintStyle: context.text.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: context.palette.textTertiary,
                        ),
                        filled: true,
                        fillColor: context.palette.inputFill,
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadii.mdAll,
                          borderSide: BorderSide(
                            color: context.palette.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadii.mdAll,
                          borderSide: BorderSide(
                            color: context.palette.selectedBorder,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),

            // Fixed Bottom CTA Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.screen),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  top: BorderSide(color: context.palette.border),
                ),
              ),
              child: PrimaryButton(
                key: const Key('request_review_button'),
                label: l10n.requestReviewButton,
                onPressed: _onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
