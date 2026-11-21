import 'package:aswani/features/places/domain/entities/place_details.dart';
import 'package:aswani/features/places/domain/entities/place_report.dart';
import 'package:aswani/shared/extensions/context_x.dart';
import 'package:aswani/shared/widgets/circle_icon_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../places_strings.dart';
import '../viewmodels/place_report_view_model.dart';
import '../widgets/report_photo_picker_box.dart';
import '../widgets/report_place_summary_card.dart';

/// Screen 10: Report Details (Place Report - Step 2) matching report_details.jpg.
/// Route: /places/:id/report/details
class PlaceReportDetailsScreen extends ConsumerStatefulWidget {
  const PlaceReportDetailsScreen({
    super.key,
    required this.placeId,
    this.place,
    this.initialReason,
    this.onBackTap,
    this.onSubmitSuccess,
  });

  final String placeId;
  final PlaceDetails? place;
  final PlaceReportReason? initialReason;
  final VoidCallback? onBackTap;
  final void Function(PlaceReportResult result)? onSubmitSuccess;

  @override
  ConsumerState<PlaceReportDetailsScreen> createState() =>
      _PlaceReportDetailsScreenState();
}

class _PlaceReportDetailsScreenState
    extends ConsumerState<PlaceReportDetailsScreen> {
  late final TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(placeReportViewModelProvider.notifier);
      vm.init(widget.placeId, place: widget.place);
      if (widget.initialReason != null) {
        vm.selectReason(widget.initialReason!);
      }
    });
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String? _resolveDetailsError(String? errorKey, PlacesStrings strings) {
    if (errorKey == null) return null;
    switch (errorKey) {
      case 'DETAILS_REQUIRED':
        return strings.reportDetailsRequired;
      case 'DETAILS_TOO_LONG':
        return strings.reportDetailsTooLong;
      default:
        return strings.reportDetailsRequired;
    }
  }

  String? _resolvePhotoError(String? errorKey, PlacesStrings strings) {
    if (errorKey == null) return null;
    switch (errorKey) {
      case 'FILE_TOO_LARGE':
        return strings.reportPhotoTooLarge;
      case 'UNSUPPORTED_FILE_TYPE':
        return strings.reportPhotoUnsupported;
      default:
        return strings.reportPhotoUnsupported;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = PlacesStrings.of(context);
    final formState = ref.watch(placeReportViewModelProvider);

    final detailsError = _resolveDetailsError(formState.detailsError, strings);
    final photoError = _resolvePhotoError(formState.photoError, strings);

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
            onPressed:
                widget.onBackTap ?? () => Navigator.of(context).maybePop(),
          ),
        ),
        title: Text(
          strings.reportDetailsTitle,
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
                      // Selected Place Summary Card
                      ReportPlaceSummaryCard(place: formState.place),
                      const SizedBox(height: 20),

                      // Details Form Field Label
                      Text(
                        strings.reportTellUs,
                        style: context.text.titleSmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.palette.ink,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Multiline Text Area with 1000 char counter
                      TextField(
                        controller: _detailsController,
                        minLines: 4,
                        maxLines: 6,
                        maxLength: 1000,
                        onChanged: (val) {
                          ref
                              .read(placeReportViewModelProvider.notifier)
                              .setDetails(val);
                        },
                        decoration: InputDecoration(
                          hintText: strings.reportDetailsHint,
                          hintStyle: TextStyle(
                            color: context.palette.textSecondary,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: context.palette.inputFill,
                          errorText: detailsError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: context.palette.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: detailsError != null
                                  ? context.colors.error
                                  : context.palette.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: detailsError != null
                                  ? context.colors.error
                                  : context.palette.link,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Supporting Photo Box
                      ReportPhotoPickerBox(
                        photoPath: formState.photo,
                        errorText: photoError,
                        onTap: () {
                          // In tests/mock mode, simulates picking a sample photo
                          ref
                              .read(placeReportViewModelProvider.notifier)
                              .setPhoto(
                                'assets/images/places/philae_temple.jpg',
                              );
                        },
                        onRemove: () {
                          ref
                              .read(placeReportViewModelProvider.notifier)
                              .removePhoto();
                        },
                      ),
                      const SizedBox(height: 20),

                      // Notice Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.palette.successTint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              LucideIcons.shieldCheck,
                              size: 20,
                              color: context.palette.link,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.reportNoticeTitle,
                                    style: context.text.titleSmall?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: context.palette.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    strings.reportNoticeSubtitle,
                                    style: context.text.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: context.palette.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Submit CTA
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: formState.isSubmitting
                        ? null
                        : () async {
                            final success = await ref
                                .read(placeReportViewModelProvider.notifier)
                                .submit();
                            if (success && mounted) {
                              final res = ref
                                  .read(placeReportViewModelProvider)
                                  .result;
                              if (res != null) {
                                widget.onSubmitSuccess?.call(res);
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: formState.isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.palette.onBrandSurface,
                            ),
                          )
                        : Text(
                            strings.reportSubmit,
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
