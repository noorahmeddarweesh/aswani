import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../domain/entities/guide_enums.dart';
import '../../domain/entities/guide_request.dart';
import '../local_guides_strings.dart';

/// Summary card displaying request parameters matching guide_request_details.jpg:
/// - White background, 1 dp border #E2EAF0, 16 dp border radius.
/// - Rows: Date, Duration, Group, Language, and conditional Interests.
/// - Divider line between each row.
class ReviewSummaryCard extends StatelessWidget {
  const ReviewSummaryCard({
    super.key,
    required this.draft,
    this.interests = const [],
  });

  final GuideRequestCreate draft;
  final List<GuideSpecialty> interests;

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: context.palette.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Row 1: Date
          _buildRow(
            context,
            label: l10n.reviewDateLabel,
            value: l10n.formatReviewDate(draft.date),
            valueKey: 'review_row_date',
          ),
          const Divider(height: 1),

          // Row 2: Duration
          _buildRow(
            context,
            label: l10n.reviewDurationLabel,
            value: l10n.reviewDurationFormatted(
              draft.duration,
              draft.durationHours,
            ),
            valueKey: 'review_row_duration',
          ),
          const Divider(height: 1),

          // Row 3: Group
          _buildRow(
            context,
            label: l10n.reviewGroupLabel,
            value: l10n.requestGroupSizeFormatted(draft.groupSize),
            valueKey: 'review_row_group',
          ),
          const Divider(height: 1),

          // Row 4: Language
          _buildRow(
            context,
            label: l10n.reviewLanguageLabel,
            value: l10n.languageLabel(draft.language),
            valueKey: 'review_row_language',
          ),

          // Row 5: Interests (Contract rule: ONLY render when non-empty)
          if (interests.isNotEmpty) ...[
            const Divider(height: 1),
            _buildRow(
              context,
              label: l10n.reviewInterestsLabel,
              value: interests
                  .map(l10n.specialtyLabel)
                  .join(context.isRtl ? '، ' : ', '),
              valueKey: 'review_row_interests',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    required String valueKey,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              fontSize: 13,
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              key: Key(valueKey),
              textAlign: TextAlign.end,
              style: context.text.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
