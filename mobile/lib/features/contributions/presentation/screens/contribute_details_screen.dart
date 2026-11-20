import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/photo_picker_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../contributions_routes.dart';
import '../../domain/entities/contribution.dart';
import '../viewmodels/contribute_view_model.dart';
import '../widgets/contribute_widgets.dart';

/// Step 2 of 3: name, category, description, address, photos and contact.
class ContributeDetailsScreen extends ConsumerStatefulWidget {
  const ContributeDetailsScreen({super.key});

  @override
  ConsumerState<ContributeDetailsScreen> createState() =>
      _ContributeDetailsScreenState();
}

class _ContributeDetailsScreenState
    extends ConsumerState<ContributeDetailsScreen> {
  late final ContributeState _start = ref.read(contributeProvider);
  late final _name = TextEditingController(text: _start.name);
  late final _description = TextEditingController(text: _start.description);
  late final _address = TextEditingController(text: _start.address);
  late final _contact = TextEditingController(text: _start.contact);
  final _scroll = ScrollController();

  @override
  void dispose() {
    for (final c in [_name, _description, _address, _contact]) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  void _next() {
    if (ref.read(contributeProvider.notifier).review()) {
      context.push(ContributeRoutes.preview);
      return;
    }
    // Show the first field with a problem.
    _scroll.animateTo(0, duration: AppMotion.medium, curve: AppMotion.standard);
  }

  Future<void> _pickCategory(ContributionCategory? current) async {
    final picked = await showModalBottomSheet<ContributionCategory>(
      context: context,
      useSafeArea: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          for (final c in ContributionCategory.values)
            ListTile(
              leading: Icon(c.icon, color: context.palette.link),
              title: Text(c.label(context.l10n)),
              trailing: c == current
                  ? Icon(LucideIcons.check, color: context.colors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(c),
            ),
        ],
      ),
    );
    if (picked != null) {
      ref.read(contributeProvider.notifier).setCategory(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(contributeProvider);
    final vm = ref.read(contributeProvider.notifier);
    String? required(ContributeField f, [String? message]) =>
        state.error(f) ? message ?? l10n.contributeErrorRequired : null;

    return Scaffold(
      appBar: AppTopBar(title: l10n.contributeDetailsTitle),
      body: MaxWidthBox(
        maxWidth: 640,
        child: ListView(
          controller: _scroll,
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.xxs,
            bottom: AppSpacing.xxl,
          ),
          children: [
            const StepBar(current: 2),
            const SizedBox(height: AppSpacing.lg),
            FormBlock(
              label: l10n.contributeName,
              required: true,
              error: required(ContributeField.name, l10n.contributeErrorName),
              child: TextField(
                controller: _name,
                onChanged: vm.setName,
                maxLength: ContributeState.maxName,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: l10n.contributeNameHint,
                  counterText: '',
                ),
              ),
            ),
            FormBlock(
              label: l10n.contributeCategory,
              required: true,
              error: required(ContributeField.category),
              child: InkWell(
                borderRadius: AppRadii.mdAll,
                onTap: () => _pickCategory(state.category),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    suffixIcon: Icon(LucideIcons.chevronDown, size: 18),
                  ),
                  child: Text(
                    state.category?.label(l10n) ?? '',
                    style: context.text.bodyLarge,
                  ),
                ),
              ),
            ),
            FormBlock(
              label: l10n.contributeDescription,
              required: true,
              error: required(ContributeField.description),
              child: TextField(
                controller: _description,
                onChanged: vm.setDescription,
                minLines: 3,
                maxLines: 5,
                maxLength: ContributeState.maxDescription,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.contributeDescriptionHint,
                  counterText: '',
                ),
              ),
            ),
            FormBlock(
              label: l10n.contributeAddress,
              required: true,
              error: required(ContributeField.address),
              child: TextField(
                controller: _address,
                onChanged: vm.setAddress,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: l10n.contributeAddressHint,
                  counterText: '',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: PhotoPickerField(
                photos: state.photos,
                onChanged: vm.setPhotos,
                title: l10n.contributePhotosTitle,
                subtitle: l10n.contributePhotosSubtitle,
              ),
            ),
            FormBlock(
              label: l10n.contributeContact,
              error: required(
                ContributeField.contact,
                l10n.contributeErrorPhone,
              ),
              child: TextField(
                controller: _contact,
                onChanged: vm.setContact,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                ],
                decoration: const InputDecoration(hintText: '+20'),
              ),
            ),
            Text(l10n.contributeContactNote, style: context.text.bodySmall),
            if (state.failure != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.errorFor(state.failure!.code),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: l10n.contributePreviewSubmit,
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}
