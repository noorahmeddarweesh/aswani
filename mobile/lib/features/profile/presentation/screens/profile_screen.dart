import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/responsive/window_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/circle_icon_button.dart';
import '../../../../shared/widgets/motion.dart';
import '../../../../shared/widgets/photo_picker_field.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../community/community_routes.dart';
import '../../../contributions/contributions_routes.dart';
import '../../../culture/culture_routes.dart';
import '../../../local_guides/guides_routes.dart';
import '../../../places/places_routes.dart';
import '../../domain/entities/profile.dart';
import '../../profile_routes.dart';
import '../viewmodels/profile_view_models.dart';
import '../widgets/profile_widgets.dart';

/// "Persona • City" under the name.
String? personaLabel(AppLocalizations l10n, String? persona) =>
    switch (persona) {
      'visitor' => l10n.personaVisitorSubtitle,
      'newcomer' => l10n.personaNewcomerSubtitle,
      'resident' => l10n.personaResidentSubtitle,
      _ => null,
    };

/// The signed-in user's profile (Home > avatar).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploading = false;

  Future<void> _changePhoto() async {
    final picked = await ref.read(pickPhotosProvider)(1);
    if (picked.isEmpty || !mounted) return;
    setState(() => _uploading = true);
    final error = await ref
        .read(profileProvider.notifier)
        .changeAvatar(picked.first);
    if (!mounted) return;
    setState(() => _uploading = false);
    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            error == null ? l10n.profilePhotoUpdated : l10n.errorFor(error),
          ),
        ),
      );
  }

  void _openSaved(SavedPreview item) {
    switch (item.type) {
      case SavedType.story:
        context.push(CultureRoutes.story(item.id));
      case SavedType.place:
        context.push(PlacesRoutes.place(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppTopBar(
        trailing: CircleIconButton(
          icon: LucideIcons.settings,
          tooltip: l10n.settingsTitle,
          onPressed: () => context.push(ProfileRoutes.settings),
        ),
      ),
      body: MaxWidthBox(
        maxWidth: 640,
        child: profile.when(
          skipLoadingOnReload: true,
          loading: () => const _ProfileSkeleton(),
          error: (error, _) => ErrorState(
            message: l10n.errorFor(
              error is Failure ? error.code : ErrorCodes.unknown,
            ),
            onRetry: () => ref.invalidate(profileProvider),
          ),
          data: (p) => RefreshIndicator(
            onRefresh: () => ref.refresh(profileProvider.future),
            child: _ProfileBody(
              profile: p,
              uploading: _uploading,
              onEditPhoto: _changePhoto,
              onOpenSaved: _openSaved,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.uploading,
    required this.onEditPhoto,
    required this.onOpenSaved,
  });

  final Profile profile;
  final bool uploading;
  final VoidCallback onEditPhoto;
  final ValueChanged<SavedPreview> onOpenSaved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = profile;
    final subtitle = [?personaLabel(l10n, p.persona), ?p.city].join(' • ');
    final c = p.contributions;

    return ListView(
      padding: AppSpacing.screenPadding.copyWith(
        top: AppSpacing.xxs,
        bottom: AppSpacing.xxl,
      ),
      children: staggered([
        Center(
          child: EditableAvatar(
            name: p.fullName,
            imageUrl: p.avatar,
            busy: uploading,
            onEdit: onEditPhoto,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          p.fullName,
          textAlign: TextAlign.center,
          style: context.text.headlineMedium,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(
              color: context.palette.link,
              fontSize: 13,
            ),
          ),
        ],
        if (p.bio case final bio? when bio.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            bio,
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(fontSize: 13),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              // Small like the design; the tap area stays 48.
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.padded,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              shape: const StadiumBorder(),
              side: BorderSide(color: context.palette.border),
              textStyle: context.text.labelMedium,
              foregroundColor: context.palette.ink,
            ),
            onPressed: () =>
                context.push(ProfileRoutes.soon(ComingSoonPage.editProfile)),
            child: Text(l10n.profileEditProfile),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfileStatsCard(stats: p.stats),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: l10n.profileSavedContent,
          actionLabel: l10n.profileViewAll,
          onAction: () => context.push(ProfileRoutes.saved),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (p.savedPreview.isEmpty)
          Text(l10n.profileSavedEmpty, style: context.text.bodySmall)
        else
          SavedPreviewStrip(items: p.savedPreview, onTap: onOpenSaved),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: l10n.profileContributions,
          actionLabel: l10n.profileDetails,
          onAction: () => context.push(ContributeRoutes.mine),
        ),
        const SizedBox(height: AppSpacing.xs),
        PointsCard(
          points: p.stats.points,
          underReview: c.reportsUnderReview,
          onTap: () => context.push(ContributeRoutes.mine),
        ),
        const SizedBox(height: AppSpacing.md),
        ProfileLinkRow(
          icon: LucideIcons.messageCircle,
          title: l10n.communityMyPosts,
          subtitle: '${p.stats.posts}',
          onTap: () => context.push(CommunityRoutes.myPosts),
        ),
        ProfileLinkRow(
          icon: LucideIcons.mapPin,
          title: l10n.contributeMine,
          subtitle: '${c.addedActivities}',
          onTap: () => context.push(ContributeRoutes.mine),
        ),
        ProfileLinkRow(
          icon: LucideIcons.calendarDays,
          title: l10n.profileGuideRequests,
          subtitle: l10n.profileGuideRequestsPending(c.guideRequestsPending),
          onTap: () => context.push(GuidesRoutes.requests),
        ),
      ]),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          SkeletonBox(
            width: 88,
            height: 88,
            borderRadius: BorderRadius.all(Radius.circular(44)),
          ),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 180, height: 24),
          SizedBox(height: AppSpacing.xs),
          SkeletonBox(width: 140, height: 14),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(height: 72),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(height: 200),
        ],
      ),
    );
  }
}
