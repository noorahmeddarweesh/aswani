import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/result/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/guide.dart';
import '../../domain/entities/guide_enums.dart';
import '../../domain/entities/guide_request.dart';
import '../../local_guides_providers.dart';
import '../local_guides_strings.dart';
import '../viewmodels/guide_details_view_model.dart';
import '../viewmodels/guide_request_view_model.dart';
import '../widgets/review_guide_card.dart';
import '../widgets/review_summary_card.dart';
import 'guide_request_submitted_screen.dart';

/// Review request screen matching guide_request_details.jpg:
/// - Top bar: back button + centered "Review request" title.
/// - Selected Guide Card (photo, "SELECTED GUIDE" eyebrow, name, "Sample profile").
/// - Request Summary Card (Date, Duration, Group, Language, conditional Interests).
/// - Availability notice card ("Availability is not guaranteed").
/// - Pinned bottom CTA: "Confirm and send request".
class GuideRequestReviewScreen extends ConsumerStatefulWidget {
  const GuideRequestReviewScreen({
    super.key,
    required this.guideId,
    this.requestDraft,
    this.onConfirmSuccess,
    this.onBackPressed,
  });

  final String guideId;
  final GuideRequestCreate? requestDraft;
  final ValueChanged<GuideRequestResult>? onConfirmSuccess;
  final VoidCallback? onBackPressed;

  @override
  ConsumerState<GuideRequestReviewScreen> createState() =>
      _GuideRequestReviewScreenState();
}

class _GuideRequestReviewScreenState
    extends ConsumerState<GuideRequestReviewScreen> {
  bool _isSubmitting = false;
  String? _errorMessage;

  void _handleBack() {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  GuideRequestCreate _resolveDraft() {
    if (widget.requestDraft != null) {
      return widget.requestDraft!;
    }
    return ref.read(guideRequestViewModelProvider(widget.guideId)).toCreatePayload();
  }

  List<GuideSpecialty> _resolveInterests(Guide? guide, GuideRequestCreate draft) {
    // 1. If draft already has explicit non-empty interests, use them.
    if (draft.interests.isNotEmpty) {
      return draft.interests;
    }
    // 2. Otherwise derive interests from the selected guide's specialties.
    if (guide != null && guide.specialties.isNotEmpty) {
      return guide.specialties;
    }
    return const [];
  }

  Future<void> _submitRequest(Guide? guide) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final draft = _resolveDraft();
    final resolvedInterests = _resolveInterests(guide, draft);

    final finalPayload = GuideRequestCreate(
      guideId: widget.guideId,
      date: draft.date,
      duration: draft.duration,
      durationHours: draft.durationHours,
      startTime: draft.startTime,
      groupSize: draft.groupSize,
      language: draft.language,
      interests: resolvedInterests,
      notes: draft.notes,
    );

    final repository = ref.read(localGuidesRepositoryProvider);
    final result = await repository.createGuideRequest(finalPayload);

    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        // Reset form state ONLY on confirmed 201 success
        ref.read(guideRequestViewModelProvider(widget.guideId).notifier).reset();
        setState(() => _isSubmitting = false);

        if (widget.onConfirmSuccess != null) {
          widget.onConfirmSuccess!(value);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => GuideRequestSubmittedScreen(
                guideId: widget.guideId,
                onHomePressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ),
          );
        }

      case Error(:final failure):
        setState(() {
          _isSubmitting = false;
          if (failure.fieldErrors['date'] == 'DATE_IN_PAST') {
            _errorMessage = context.guidesL10n.requestDateInPast;
          } else if (failure.code == 'GUIDE_NOT_FOUND') {
            _errorMessage = context.guidesL10n.guideNotFound;
          } else {
            _errorMessage = context.guidesL10n.errorLoading;
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;
    final guideAsync = ref.watch(guideDetailsProvider(widget.guideId));
    final draft = _resolveDraft();

    final guide = guideAsync.asData?.value;
    final resolvedInterests = _resolveInterests(guide, draft);

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
                        l10n.reviewScreenTitle,
                        style: context.text.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.palette.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balances 40dp back button
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Selected Guide Card
                    if (guide != null)
                      ReviewGuideCard(
                        key: const Key('review_guide_card'),
                        guide: guide,
                      )
                    else
                      Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color: context.palette.surfaceMuted,
                          borderRadius: AppRadii.lgAll,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.selectedGuideEyebrow,
                          style: context.text.bodySmall?.copyWith(
                            color: context.palette.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),

                    // 2. Request Summary Card
                    ReviewSummaryCard(
                      key: const Key('review_summary_card'),
                      draft: draft,
                      interests: resolvedInterests,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 3. Availability Information Card
                    Container(
                      key: const Key('review_availability_banner'),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: context.palette.successTint,
                        borderRadius: AppRadii.mdAll,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 20,
                            color: context.palette.selectedBorder,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.availabilityNoticeTitle,
                                  style: context.text.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: context.palette.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.availabilityNoticeSubtitle,
                                  style: context.text.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: context.palette.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Error Banner (if error occurred during submission)
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        key: const Key('review_error_banner'),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: context.colors.error.withValues(alpha: 0.1),
                          borderRadius: AppRadii.mdAll,
                          border: Border.all(color: context.colors.error),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.alertCircle,
                              size: 18,
                              color: context.colors.error,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: context.text.bodySmall?.copyWith(
                                  color: context.colors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Pinned Bottom Action CTA
            Container(
              padding: const EdgeInsets.all(AppSpacing.screen),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  top: BorderSide(color: context.palette.border),
                ),
              ),
              child: PrimaryButton(
                key: const Key('review_confirm_button'),
                label: l10n.confirmAndSendRequest,
                loading: _isSubmitting,
                onPressed: _isSubmitting ? null : () => _submitRequest(guide),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
