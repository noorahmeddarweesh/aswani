import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/photo_picker_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/network/upload.dart';
import '../../community_routes.dart';
import '../../domain/entities/post.dart';
import '../viewmodels/new_post_view_model.dart';
import '../widgets/community_labels.dart';

/// "New post": up to 6 photos, a caption, an optional location and the
/// category. Publish is enabled once there is a photo and a caption.
class NewPostScreen extends ConsumerStatefulWidget {
  const NewPostScreen({super.key, this.source});

  /// "Share your moment": open the camera or the gallery at once.
  final MomentSource? source;

  @override
  ConsumerState<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends ConsumerState<NewPostScreen> {
  final _caption = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.source != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickFirst());
    }
  }

  Future<void> _pickFirst() async {
    final photos = switch (widget.source!) {
      MomentSource.camera => [?await ref.read(takePhotoProvider)()],
      MomentSource.gallery => await ref.read(pickPhotosProvider)(
        UploadRules.maxPhotos,
      ),
    };
    if (!mounted || photos.isEmpty) return;
    final accepted = [
      for (final p in photos)
        if (checkUpload(p) == null) p,
    ];
    if (accepted.length < photos.length) {
      final problem = photos.map(checkUpload).nonNulls.first;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorFor(problem))));
    }
    ref.read(newPostProvider.notifier).setPhotos(accepted);
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.communityPosted;
    final post = await ref.read(newPostProvider.notifier).publish();
    if (post == null || !mounted) return;
    context.pop(post);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editLocation(String current) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _LocationSheet(initial: current),
    );
    if (value != null) ref.read(newPostProvider.notifier).setLocation(value);
  }

  Future<void> _pickCategory(PostCategory current) async {
    final value = await showModalBottomSheet<PostCategory>(
      context: context,
      useSafeArea: true,
      builder: (context) => _CategorySheet(selected: current),
    );
    if (value != null) ref.read(newPostProvider.notifier).setCategory(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(newPostProvider);
    final vm = ref.read(newPostProvider.notifier);
    final failure = state.failure;
    final photosError = failure?.fieldErrors['images'];

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.communityNewPost,
        trailing: TextButton(
          onPressed: state.canPublish ? _publish : null,
          child: Text(l10n.communityPublish),
        ),
      ),
      body: MaxWidthBox(
        maxWidth: 640,
        child: ListView(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.xs,
            bottom: AppSpacing.xxl,
          ),
          children: staggered([
            PhotoPickerField(
              photos: state.photos,
              onChanged: vm.setPhotos,
              title: l10n.communityAddPhotosTitle,
              subtitle: l10n.communityAddPhotosSubtitle,
              buttonLabel: l10n.photosChoose,
              errorText: photosError == null
                  ? null
                  : l10n.errorFor(photosError),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.communityCaptionLabel, style: context.text.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _caption,
              onChanged: vm.setCaption,
              minLines: 3,
              maxLines: 6,
              maxLength: NewPostViewModel.maxCaption,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.communityCaptionHint,
                counterText: '',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _OptionRow(
              icon: LucideIcons.mapPin,
              title: l10n.communityAddLocation,
              value: state.location.isEmpty ? l10n.optional : state.location,
              onTap: () => _editLocation(state.location),
            ),
            const Divider(height: 1),
            _OptionRow(
              icon: LucideIcons.palette,
              title: l10n.communityPostCategory,
              value: state.category.label(l10n),
              onTap: () => _pickCategory(state.category),
            ),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.communityRespectNote,
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
            if (failure != null && photosError == null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.errorFor(failure.code),
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: l10n.communityPublishToCommunity,
              loading: state.submitting,
              onPressed: state.canPublish ? _publish : null,
            ),
          ]),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.palette.link),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRightDir,
              size: 18,
              color: context.palette.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSheet extends StatefulWidget {
  const _LocationSheet({required this.initial});

  final String initial;

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.communityAddLocation, style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 100,
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.of(context).pop(v),
            decoration: InputDecoration(
              hintText: l10n.communityLocationHint,
              prefixIcon: const Icon(LucideIcons.mapPin, size: 18),
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.selected});

  final PostCategory selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Text(
              l10n.communityPostCategory,
              style: context.text.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final category in PostCategory.values)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screen,
              ),
              title: Text(category.label(l10n)),
              trailing: category == selected
                  ? Icon(LucideIcons.check, color: context.colors.primary)
                  : null,
              selected: category == selected,
              onTap: () => Navigator.of(context).pop(category),
            ),
        ],
      ),
    );
  }
}
