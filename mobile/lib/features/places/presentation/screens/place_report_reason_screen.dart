import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/shared/extensions/context_x.dart';
import 'package:aswani/shared/widgets/circle_icon_button.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../places_strings.dart';
import '../viewmodels/place_report_view_model.dart';
import '../widgets/report_reason_option_card.dart';

/// Screen 9: What Needs Updating (Place Report - Step 1) matching report.jpg.
/// Route: /places/:id/report
class PlaceReportReasonScreen extends ConsumerStatefulWidget {
  const PlaceReportReasonScreen({
    super.key,
    required this.placeId,
    this.place,
    this.onBackTap,
    this.onContinue,
  });

  final String placeId;
  final PlaceDetails? place;
  final VoidCallback? onBackTap;
  final void Function(PlaceReportReason reason)? onContinue;

  @override
  ConsumerState<PlaceReportReasonScreen> createState() =>
      _PlaceReportReasonScreenState();
}

class _PlaceReportReasonScreenState
    extends ConsumerState<PlaceReportReasonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(placeReportViewModelProvider.notifier)
          .init(widget.placeId, place: widget.place);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);
    final formState = ref.watch(placeReportViewModelProvider);
    final selectedReason = formState.reason;

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: CircleIconButton.back(
            tooltip: strings.back,
            onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
          ),
        ),
        title: Text(
          strings.reportTitle,
          style: context.text.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.palette.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Eyebrow
                      Text(
                        strings.reportEyebrow,
                        style: context.text.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: context.palette.link,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        strings.reportWhatNeedsUpdating,
                        style: context.text.headlineMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: context.palette.ink,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        strings.reportSubtitle,
                        style: context.text.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: context.palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Reason Cards List
                      for (final reason in PlaceReportReason.values) ...[
                        ReportReasonOptionCard(
                          title: strings.reasonLabel(reason),
                          isSelected: selectedReason == reason,
                          onTap: () {
                            ref
                                .read(placeReportViewModelProvider.notifier)
                                .selectReason(reason);
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom Continue CTA
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: formState.canContinueFromReason
                        ? () {
                            widget.onContinue?.call(selectedReason!);
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      strings.reportContinue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
