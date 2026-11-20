import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/utils/relative_time.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/bookmark_icon.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../domain/entities/post.dart';

/// Author, location and time ("Aswan Corniche • 2h").
class PostAuthorRow extends StatelessWidget {
  const PostAuthorRow({
    super.key,
    required this.post,
    this.avatarSize = 36,
    this.trailing,
  });

  final Post post;
  final double avatarSize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final time = relativeTime(context.l10n, post.createdAt);
    final place = post.location;
    return Row(
      children: [
        UserAvatar(
          name: post.author.fullName,
          imageUrl: post.author.avatarUrl,
          size: avatarSize,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.author.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleSmall?.copyWith(fontSize: 13),
              ),
              Row(
                children: [
                  if (place != null) ...[
                    Icon(
                      LucideIcons.mapPin,
                      size: 12,
                      color: context.palette.textSecondary,
                    ),
                    const SizedBox(width: 2),
                  ],
                  Flexible(
                    child: Text(
                      place == null ? time : '$place • $time',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// The post's photos: swipe between them, with dots under several photos.
class PostImages extends StatefulWidget {
  const PostImages({super.key, required this.images, this.aspectRatio = 1.1});

  final List<String> images;
  final double aspectRatio;

  @override
  State<PostImages> createState() => _PostImagesState();
}

class _PostImagesState extends State<PostImages> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Semantics(
              label: context.l10n.communityPhotoOf(i + 1, images.length),
              image: true,
              child: AppImage(images[i]),
            ),
          ),
          if (images.length > 1)
            PositionedDirectional(
              bottom: AppSpacing.xs,
              start: 0,
              end: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: AppMotion.short,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: i == _index ? 14 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: context.palette.onBrandSurface.withValues(
                          alpha: i == _index ? 1 : 0.6,
                        ),
                        borderRadius: AppRadii.pillAll,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Caption with #hashtags in the link colour.
class CaptionText extends StatelessWidget {
  const CaptionText(this.text, {super.key, this.maxLines});

  final String text;
  final int? maxLines;

  static final _tag = RegExp(r'#[\p{L}\p{N}_]+', unicode: true);

  @override
  Widget build(BuildContext context) {
    final base = context.text.bodyMedium?.copyWith(
      fontSize: 13,
      color: context.palette.ink,
      height: 1.45,
    );
    final spans = <TextSpan>[];
    var last = 0;
    for (final m in _tag.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(
        TextSpan(
          text: m.group(0),
          style: TextStyle(color: context.palette.link),
        ),
      );
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

/// Heart that fills (gold) and pops when the post is appreciated.
class LikeIcon extends StatelessWidget {
  const LikeIcon({super.key, required this.liked, this.size = 22});

  final bool liked;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(
        liked ? Icons.favorite : LucideIcons.heart,
        key: ValueKey(liked),
        size: size,
        color: liked ? context.palette.accentGold : context.palette.ink,
      ),
    );
  }
}

/// A small icon button with the 48 dp touch area of the design system.
class PostAction extends StatelessWidget {
  const PostAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.label,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: AppRadii.pillAll,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 40, minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                if (label != null) ...[
                  const SizedBox(width: 4),
                  Text(label!, style: context.text.bodySmall),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A post in the feed (and in My posts).
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onOpen,
    required this.onLike,
    required this.onBookmark,
    required this.onShare,
    required this.onComments,
    required this.onLikes,
    this.onDelete,
  });

  final Post post;
  final VoidCallback onOpen;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  /// Opens the comments sheet.
  final VoidCallback onComments;

  /// Opens who appreciated the post.
  final VoidCallback onLikes;

  /// Shown in the "…" menu only for the user's own posts.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.lgAll,
        side: BorderSide(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xxs,
              AppSpacing.sm,
            ),
            child: PostAuthorRow(
              post: post,
              trailing: PostMenu(onDelete: onDelete, onShare: onShare),
            ),
          ),
          LikeOnDoubleTap(
            liked: post.isLiked,
            onLike: onLike,
            onTap: onOpen,
            child: PostImages(images: post.images),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Row(
              children: [
                PostAction(
                  icon: LikeIcon(liked: post.isLiked),
                  tooltip: post.isLiked
                      ? l10n.communityUnlike
                      : l10n.communityLike,
                  onPressed: onLike,
                ),
                PostAction(
                  icon: Icon(
                    LucideIcons.messageCircle,
                    size: 22,
                    color: palette.ink,
                  ),
                  tooltip: l10n.communityComment,
                  onPressed: onComments,
                ),
                PostAction(
                  icon: Icon(LucideIcons.share2, size: 22, color: palette.ink),
                  tooltip: l10n.share,
                  onPressed: onShare,
                ),
                const Spacer(),
                PostAction(
                  icon: BookmarkIcon(saved: post.isBookmarked, size: 22),
                  tooltip: post.isBookmarked
                      ? l10n.communityUnsave
                      : l10n.communitySave,
                  onPressed: onBookmark,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onLikes,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      l10n.communityAppreciations(post.likeCount),
                      style: context.text.bodySmall?.copyWith(
                        fontSize: 12,
                        color: context.palette.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onOpen,
                  child: CaptionText(post.caption, maxLines: 4),
                ),
                if (post.commentCount > 0)
                  InkWell(
                    onTap: onComments,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: Text(
                        l10n.communityViewComments(post.commentCount),
                        style: context.text.bodySmall,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "…" button: Share for every post, Delete for the user's own.
class PostMenu extends StatelessWidget {
  const PostMenu({super.key, this.onDelete, this.onShare, this.filled = false});

  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  /// Round grey button, as in the post page's top bar.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final menu = PopupMenuButton<String>(
      tooltip: l10n.communityMore,
      icon: Icon(LucideIcons.ellipsis, color: context.palette.ink),
      enabled: onDelete != null || onShare != null,
      itemBuilder: (context) => [
        if (onShare != null)
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(LucideIcons.share2, size: 18, color: context.palette.ink),
                const SizedBox(width: AppSpacing.xs),
                Text(l10n.share),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(LucideIcons.trash2, size: 18, color: context.colors.error),
                const SizedBox(width: AppSpacing.xs),
                Text(l10n.communityDeletePost),
              ],
            ),
          ),
      ],
      onSelected: (value) => switch (value) {
        'share' => onShare?.call(),
        'delete' => onDelete?.call(),
        _ => null,
      },
    );
    if (!filled) return menu;
    return SizedBox.square(
      dimension: AppSpacing.minTouchTarget,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.palette.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: Center(child: menu),
        ),
      ),
    );
  }
}

/// Double-tap to appreciate, as in Instagram: a big heart pops over the
/// photo. A second double tap never takes the appreciation back.
class LikeOnDoubleTap extends StatefulWidget {
  const LikeOnDoubleTap({
    super.key,
    required this.liked,
    required this.onLike,
    required this.child,
    this.onTap,
  });

  final bool liked;
  final VoidCallback onLike;
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<LikeOnDoubleTap> createState() => _LikeOnDoubleTapState();
}

class _LikeOnDoubleTapState extends State<LikeOnDoubleTap>
    with SingleTickerProviderStateMixin {
  late final _heart = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void dispose() {
    _heart.dispose();
    super.dispose();
  }

  void _doubleTap() {
    if (!widget.liked) widget.onLike();
    _heart.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.2,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 20),
    ]).animate(_heart);
    final opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_heart);
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: _doubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _heart,
              builder: (context, child) => _heart.isAnimating
                  ? Opacity(
                      opacity: opacity.value,
                      child: Transform.scale(scale: scale.value, child: child),
                    )
                  : const SizedBox.shrink(),
              child: Icon(
                Icons.favorite,
                size: 96,
                color: context.palette.onBrandSurface,
                shadows: [
                  Shadow(
                    blurRadius: 24,
                    color: context.colors.scrim.withValues(alpha: 0.33),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shaped like a post while the feed loads.
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SkeletonBox(width: 36, height: 36, borderRadius: AppRadii.pillAll),
            SizedBox(width: AppSpacing.xs),
            SkeletonBox(width: 140, height: 14),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AspectRatio(aspectRatio: 1.1, child: SkeletonBox()),
        SizedBox(height: AppSpacing.sm),
        SkeletonBox(width: 220, height: 14),
      ],
    );
  }
}
