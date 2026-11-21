import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../core/result/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/labeled_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/guide_application.dart';
import '../../domain/entities/guide_enums.dart';
import '../local_guides_strings.dart';
import '../viewmodels/guide_application_view_model.dart';
import '../widgets/guide_photo_picker_tile.dart';
import '../widgets/multi_select_bottom_sheet.dart';

/// Screen for applying to become a local guide matching guide_application.jpg.
class GuideApplicationScreen extends ConsumerStatefulWidget {
  const GuideApplicationScreen({
    super.key,
    this.onSubmittedSuccess,
    this.onPickPhoto,
  });

  final ValueChanged<GuideApplicationResult>? onSubmittedSuccess;

  /// Injectable photo picker callback (since image_picker is not in pubspec.yaml).
  final Future<String?> Function()? onPickPhoto;

  @override
  ConsumerState<GuideApplicationScreen> createState() =>
      _GuideApplicationScreenState();
}

class _GuideApplicationScreenState
    extends ConsumerState<GuideApplicationScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(guideApplicationViewModelProvider);
    _nameController = TextEditingController(text: state.fullName);
    _bioController = TextEditingController(text: state.bio);
    _contactController = TextEditingController(text: state.contact);

    _nameController.addListener(() {
      final vm = ref.read(guideApplicationViewModelProvider.notifier);
      if (_nameController.text !=
          ref.read(guideApplicationViewModelProvider).fullName) {
        vm.setFullName(_nameController.text);
      }
    });

    _bioController.addListener(() {
      final vm = ref.read(guideApplicationViewModelProvider.notifier);
      if (_bioController.text !=
          ref.read(guideApplicationViewModelProvider).bio) {
        vm.setBio(_bioController.text);
      }
    });

    _contactController.addListener(() {
      final vm = ref.read(guideApplicationViewModelProvider.notifier);
      if (_contactController.text !=
          ref.read(guideApplicationViewModelProvider).contact) {
        vm.setContact(_contactController.text);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  String _resolveErrorMessage(String code, LocalGuidesStrings l10n) {
    switch (code) {
      case 'REQUIRED':
        return l10n.fieldRequired;
      case 'INVALID_PHONE':
        return l10n.invalidPhone;
      case 'TOO_SHORT':
        return l10n.bioTooShort;
      case 'ALREADY_APPLIED':
        return l10n.alreadyApplied;
      case 'FILE_TOO_LARGE':
        return l10n.fileTooLarge;
      case 'UNSUPPORTED_FILE_TYPE':
        return l10n.unsupportedFileType;
      default:
        return code;
    }
  }

  Future<void> _handlePhotoPick() async {
    final viewModel = ref.read(guideApplicationViewModelProvider.notifier);

    if (widget.onPickPhoto != null) {
      final path = await widget.onPickPhoto!();
      viewModel.setProfilePhoto(path);
      return;
    }

    // Default mock behavior if no external picker is injected.
    // In demo/test environment without image_picker plugin,
    // toggles a sample mock image asset.
    final currentPhoto = ref
        .read(guideApplicationViewModelProvider)
        .profilePhoto;
    if (currentPhoto == null || currentPhoto.isEmpty) {
      viewModel.setProfilePhoto(AppImages.avatarLaila);
    } else {
      viewModel.setProfilePhoto(null);
    }
  }

  Future<void> _handleSubmit() async {
    final viewModel = ref.read(guideApplicationViewModelProvider.notifier);
    final result = await viewModel.submit();

    if (!mounted) return;

    if (result case Success(:final value)) {
      viewModel.reset();
      widget.onSubmittedSuccess?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.guidesL10n;
    final state = ref.watch(guideApplicationViewModelProvider);
    final viewModel = ref.read(guideApplicationViewModelProvider.notifier);

    ref.listen(guideApplicationViewModelProvider, (prev, next) {
      if (next.fullName.isEmpty && _nameController.text.isNotEmpty) {
        _nameController.clear();
      }
      if (next.bio.isEmpty && _bioController.text.isNotEmpty) {
        _bioController.clear();
      }
      if (next.contact.isEmpty && _contactController.text.isNotEmpty) {
        _contactController.clear();
      }
    });

    // Format selected languages label
    final languagesText = state.languages.isEmpty
        ? ''
        : state.languages.map(l10n.languageLabel).join(', ');

    // Format selected specialties label
    final specialtiesText = state.specialties.isEmpty
        ? ''
        : state.specialties.map(l10n.specialtyLabel).join(', ');

    // Format selected durations label
    final durationsText = state.durations.isEmpty
        ? ''
        : state.durations.map(l10n.durationLabel).join(', ');

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
          child: CircleIconButton.back(
            tooltip: l10n.back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: Text(
          l10n.applyTitle,
          style: context.text.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.palette.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screen,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Intro text
                    Text(
                      l10n.applyIntro,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Profile photo picker
                    GuidePhotoPickerTile(
                      photoPath: state.profilePhoto,
                      onTap: _handlePhotoPick,
                      onRemove: state.profilePhoto != null
                          ? () => viewModel.setProfilePhoto(null)
                          : null,
                      errorText: state.photoError != null
                          ? _resolveErrorMessage(state.photoError!, l10n)
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Server error banner (e.g., ALREADY_APPLIED or generic)
                    if (state.serverError != null) ...[
                      Container(
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
                                _resolveErrorMessage(state.serverError!, l10n),
                                style: context.text.bodySmall?.copyWith(
                                  color: context.colors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Field 1: Full name *
                    AppTextField(
                      label: l10n.fullNameLabel,
                      controller: _nameController,
                      hint: l10n.fullNameHint,
                      serverError: state.fullNameError != null
                          ? _resolveErrorMessage(state.fullNameError!, l10n)
                          : null,
                      textInputAction: TextInputAction.next,
                      onSubmitted: viewModel.setFullName,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Field 2: Languages * (Tappable modal selector)
                    _TappableSelectorField(
                      label: l10n.languagesLabel,
                      hint: l10n.languagesHint,
                      valueText: languagesText,
                      errorText: state.languagesError != null
                          ? _resolveErrorMessage(state.languagesError!, l10n)
                          : null,
                      onTap: () {
                        MultiSelectBottomSheet.show<GuideLanguage>(
                          context: context,
                          title: l10n.selectLanguages,
                          items: GuideLanguage.values,
                          selectedItems: state.languages,
                          itemLabel: l10n.languageLabel,
                          onConfirm: viewModel.setLanguages,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Field 3: Tour specialties * (Tappable modal selector)
                    _TappableSelectorField(
                      label: l10n.specialtiesLabel,
                      hint: l10n.specialtiesHint,
                      valueText: specialtiesText,
                      errorText: state.specialtiesError != null
                          ? _resolveErrorMessage(state.specialtiesError!, l10n)
                          : null,
                      onTap: () {
                        MultiSelectBottomSheet.show<GuideSpecialty>(
                          context: context,
                          title: l10n.selectSpecialties,
                          items: GuideSpecialty.values,
                          selectedItems: state.specialties,
                          itemLabel: l10n.specialtyLabel,
                          onConfirm: viewModel.setSpecialties,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Field 4: Short biography * (Multiline text area)
                    LabeledField(
                      label: l10n.bioLabel,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _bioController,
                            maxLines: 4,
                            onChanged: viewModel.setBio,
                            style: context.text.bodyLarge,
                            decoration: InputDecoration(
                              hintText: l10n.bioHint,
                              errorText: state.bioError != null
                                  ? _resolveErrorMessage(state.bioError!, l10n)
                                  : null,
                              errorMaxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Field 5: Available durations (Tappable modal selector)
                    _TappableSelectorField(
                      label: l10n.durationsLabel,
                      hint: l10n.durationsHint,
                      valueText: durationsText,
                      errorText: state.durationsError != null
                          ? _resolveErrorMessage(state.durationsError!, l10n)
                          : null,
                      onTap: () {
                        MultiSelectBottomSheet.show<GuideDuration>(
                          context: context,
                          title: l10n.selectDurations,
                          items: GuideDuration.values,
                          selectedItems: state.durations,
                          itemLabel: l10n.durationLabel,
                          onConfirm: viewModel.setDurations,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Field 6: Contact details * (Egyptian mobile number)
                    AppTextField(
                      label: l10n.contactLabel,
                      controller: _contactController,
                      hint: l10n.contactHint,
                      keyboardType: TextInputType.phone,
                      serverError: state.contactError != null
                          ? _resolveErrorMessage(state.contactError!, l10n)
                          : null,
                      textInputAction: TextInputAction.done,
                      onSubmitted: viewModel.setContact,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Pinned bottom submit CTA
            Container(
              padding: const EdgeInsets.all(AppSpacing.screen),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(
                  top: BorderSide(color: context.palette.border, width: 1),
                ),
              ),
              child: PrimaryButton(
                label: l10n.submitApplication,
                loading: state.isSubmitting,
                onPressed: () {
                  viewModel.setFullName(_nameController.text);
                  viewModel.setBio(_bioController.text);
                  viewModel.setContact(_contactController.text);
                  _handleSubmit();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget to render multi-select fields looking visually like text fields in Figma.
class _TappableSelectorField extends StatelessWidget {
  const _TappableSelectorField({
    required this.label,
    required this.hint,
    required this.valueText,
    this.errorText,
    required this.onTap,
  });

  final String label;
  final String hint;
  final String valueText;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = valueText.isNotEmpty;

    return LabeledField(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: AppRadii.mdAll,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: context.palette.inputFill,
                borderRadius: AppRadii.mdAll,
                border: Border.all(
                  color: errorText != null
                      ? context.colors.error
                      : context.palette.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? valueText : hint,
                      style: hasValue
                          ? context.text.bodyLarge?.copyWith(
                              color: context.palette.ink,
                            )
                          : context.text.bodyLarge?.copyWith(
                              color: context.palette.textTertiary,
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: context.palette.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
