import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/utils/relative_time.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../community_providers.dart';
import '../../community_routes.dart';
import '../../domain/entities/post.dart';
import '../viewmodels/community_feed_view_model.dart';
import '../viewmodels/post_likes_view_model.dart';
import '../widgets/post_widgets.dart';

/// Stories of the highlight circles, full screen like Instagram: bars on
/// top fill as each photo plays, tap the sides to go back or forward, hold
/// to pause, swipe sideways for the next circle, drag down to close.
/// Appreciate a moment or open its post; there is no chat.
class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({super.key, required this.highlightId});

  final String highlightId;

  /// How long one photo stays.
  static const slide = Duration(seconds: 5);

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  PageController? _pages;
  int _current = 0;

  /// Drag-down distance; the viewer follows the finger, then closes.
  double _drag = 0;
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(() => setState(() => _drag = _dragFrom * (1 - _settle.value)));
  double _dragFrom = 0;

  @override
  void dispose() {
    _pages?.dispose();
    _settle.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) context.pop();
  }

  void _toPage(int index, int count) {
    if (index < 0) return;
    if (index >= count) return _close();
    _pages?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _dragEnd(DragEndDetails details) {
    if (_drag > 140 || details.primaryVelocity! > 800) return _close();
    _dragFrom = _drag;
    _settle.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(communityFeedProvider);
    final highlights = feed.value?.highlights;
    Widget body;
    if (highlights == null) {
      body = feed.hasError
          ? _Message(
              text: context.l10n.errorFor(feedErrorCode(feed.error!)),
              onClose: _close,
            )
          : Center(
              child: CircularProgressIndicator(
                color: context.palette.onBrandSurface,
              ),
            );
    } else {
      final start = highlights.indexWhere((h) => h.id == widget.highlightId);
      if (start < 0) {
        body = _Message(text: context.l10n.storyEmpty, onClose: _close);
      } else {
        if (_pages == null) {
          _current = start;
          _pages = PageController(initialPage: start);
        }
        body = PageView.builder(
          controller: _pages,
          itemCount: highlights.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, i) => _HighlightStories(
            highlight: highlights[i],
            active: i == _current && _drag == 0,
            onDone: () => _toPage(i + 1, highlights.length),
            onBeforeFirst: () => _toPage(i - 1, highlights.length),
            onClose: _close,
          ),
        );
      }
    }

    final progress = (_drag / 400).clamp(0.0, 1.0);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.colors.scrim.withValues(
          alpha: 1 - progress * 0.6,
        ),
        body: GestureDetector(
          onVerticalDragUpdate: (d) =>
              setState(() => _drag = (_drag + d.delta.dy).clamp(0, 600)),
          onVerticalDragEnd: _dragEnd,
          child: Transform.translate(
            offset: Offset(0, _drag),
            child: Transform.scale(scale: 1 - progress * 0.15, child: body),
          ),
        ),
      ),
    );
  }
}

/// The photos of one circle.
class _HighlightStories extends ConsumerStatefulWidget {
  const _HighlightStories({
    required this.highlight,
    required this.active,
    required this.onDone,
    required this.onBeforeFirst,
    required this.onClose,
  });

  final Highlight highlight;

  /// Only the circle on screen plays.
  final bool active;
  final VoidCallback onDone;
  final VoidCallback onBeforeFirst;
  final VoidCallback onClose;

  @override
  ConsumerState<_HighlightStories> createState() => _HighlightStoriesState();
}

class _HighlightStoriesState extends ConsumerState<_HighlightStories>
    with SingleTickerProviderStateMixin {
  // A clock, not an animation: "reduce motion" must not make it 20x
  // shorter, so it keeps its time.
  late final AnimationController _timer =
      AnimationController(
        vsync: this,
        duration: StoryViewerScreen.slide,
        animationBehavior: AnimationBehavior.preserve,
      )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _next();
      });

  int _index = 0;
  bool _held = false;

  /// Appreciations changed here, by post id.
  final Map<String, Post> _changed = {};

  List<Post>? get _moments =>
      ref.read(highlightMomentsProvider(widget.highlight.category)).value;

  @override
  void didUpdateWidget(_HighlightStories old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) _sync();
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  /// Plays when on screen, loaded and not held; pauses otherwise.
  void _sync() {
    final ready = (_moments?.isNotEmpty ?? false) && widget.active && !_held;
    if (ready) {
      _timer.forward();
    } else {
      _timer.stop();
    }
  }

  void _show(int index) {
    setState(() => _index = index);
    _timer.value = 0;
    _sync();
  }

  void _next() {
    final count = _moments?.length ?? 0;
    if (_index < count - 1) return _show(_index + 1);
    widget.onDone();
  }

  void _previous() {
    if (_index > 0) return _show(_index - 1);
    widget.onBeforeFirst();
    _show(0);
  }

  void _hold(bool held) {
    setState(() => _held = held);
    _sync();
  }

  void _tap(TapUpDetails details, double width) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final x = details.localPosition.dx;
    final fromStart = rtl ? width - x : x;
    fromStart < width / 3 ? _previous() : _next();
  }

  Future<void> _toggleLike(Post post) async {
    final liked = !post.isLiked;
    final updated = post.copyWith(
      isLiked: liked,
      likeCount: post.likeCount + (liked ? 1 : -1),
    );
    setState(() => _changed[post.id] = updated);
    final result = await ref
        .read(communityRepositoryProvider)
        .setLiked(post.id, liked: liked);
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        final saved = updated.copyWith(likeCount: value);
        setState(() => _changed[post.id] = saved);
        if (ref.read(communityFeedProvider.exists)) {
          ref.read(communityFeedProvider.notifier).replace(saved);
        }
      case Error(:final failure):
        setState(() => _changed[post.id] = post);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(context.l10n.errorFor(failure.code))),
          );
    }
  }

  Future<void> _openPost(Post post) async {
    _hold(true);
    await context.push(CommunityRoutes.post(post.id));
    if (mounted) _hold(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final moments = ref.watch(
      highlightMomentsProvider(widget.highlight.category),
    );
    ref.listen(highlightMomentsProvider(widget.highlight.category), (_, next) {
      if (next.hasValue) _sync();
    });

    return moments.when(
      skipLoadingOnReload: true,
      loading: () => _Frame(
        highlight: widget.highlight,
        onClose: widget.onClose,
        child: Center(
          child: CircularProgressIndicator(
            color: context.palette.onBrandSurface,
          ),
        ),
      ),
      error: (error, _) => _Message(
        text: l10n.errorFor(error is Failure ? error.code : ErrorCodes.unknown),
        onClose: widget.onClose,
        onRetry: () =>
            ref.invalidate(highlightMomentsProvider(widget.highlight.category)),
      ),
      data: (list) {
        if (list.isEmpty) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDone,
            child: _Message(text: l10n.storyEmpty, onClose: widget.onClose),
          );
        }
        final index = _index.clamp(0, list.length - 1);
        final post = _changed[list[index].id] ?? list[index];
        return LayoutBuilder(
          builder: (context, box) => Semantics(
            label: l10n.storyOf(index + 1, list.length),
            customSemanticsActions: {
              CustomSemanticsAction(label: l10n.storyNext): _next,
              CustomSemanticsAction(label: l10n.storyPrevious): _previous,
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _tap(d, box.maxWidth),
              onLongPressStart: (_) => _hold(true),
              onLongPressEnd: (_) => _hold(false),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    post.images.first,
                    key: ValueKey(post.id),
                    fit: BoxFit.cover,
                  ),
                  // Hidden while held, so the photo can be seen whole.
                  AnimatedOpacity(
                    opacity: _held ? 0 : 1,
                    duration: const Duration(milliseconds: 150),
                    child: _Frame(
                      highlight: widget.highlight,
                      post: post,
                      onClose: widget.onClose,
                      progress: _Bars(
                        count: list.length,
                        index: index,
                        timer: _timer,
                      ),
                      bottom: _Actions(
                        post: post,
                        onLike: () => _toggleLike(post),
                        onOpen: () => _openPost(post),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bars, header and the bottom part over the photo, with soft shades so
/// white text stays readable.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.highlight,
    required this.onClose,
    this.post,
    this.progress,
    this.bottom,
    this.child,
  });

  final Highlight highlight;
  final Post? post;
  final VoidCallback onClose;
  final Widget? progress;
  final Widget? bottom;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final shade = context.colors.scrim.withValues(alpha: 0.6);
    final white = context.palette.onBrandSurface;
    return Stack(
      fit: StackFit.expand,
      children: [
        ?child,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [shade, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [shade, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ?progress,
                const SizedBox(height: AppSpacing.xs),
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.4,
                  child: Row(
                    children: [
                      const SizedBox(width: AppSpacing.xxs),
                      if (post != null)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: white, width: 1.5),
                          ),
                          child: UserAvatar(
                            name: post!.author.fullName,
                            imageUrl: post!.author.avatarUrl,
                            size: 34,
                          ),
                        ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        post?.author.fullName ??
                                        highlight.title(lang),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (post != null)
                                    TextSpan(
                                      text:
                                          '  ${relativeTime(l10n, post!.createdAt)}',
                                      style: TextStyle(
                                        color: white.withValues(alpha: 0.75),
                                      ),
                                    ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyMedium?.copyWith(
                                color: white,
                              ),
                            ),
                            if (post != null)
                              Text(
                                highlight.title(lang),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall?.copyWith(
                                  color: white.withValues(alpha: 0.75),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.storyClose,
                        onPressed: onClose,
                        icon: Icon(LucideIcons.x, color: white),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ?bottom,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One bar per photo: done ones full, the current one filling.
class _Bars extends StatelessWidget {
  const _Bars({required this.count, required this.index, required this.timer});

  final int count;
  final int index;
  final Animation<double> timer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: AppRadii.pillAll,
              child: SizedBox(
                height: 2.5,
                child: ColoredBox(
                  color: context.palette.onBrandSurface.withValues(alpha: 0.35),
                  child: i == index
                      ? AnimatedBuilder(
                          animation: timer,
                          builder: (_, _) => _Fill(timer.value),
                        )
                      : _Fill(i < index ? 1 : 0),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Fill extends StatelessWidget {
  const _Fill(this.value);

  final double value;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: value,
      child: ColoredBox(color: context.palette.onBrandSurface),
    );
  }
}

/// Caption, appreciate and "View post".
class _Actions extends StatelessWidget {
  const _Actions({
    required this.post,
    required this.onLike,
    required this.onOpen,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final white = context.palette.onBrandSurface;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              post.caption,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(color: white),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                IconButton(
                  tooltip: post.isLiked
                      ? l10n.communityUnlike
                      : l10n.communityLike,
                  onPressed: onLike,
                  icon: post.isLiked
                      ? const LikeIcon(liked: true, size: 28)
                      : Icon(LucideIcons.heart, size: 28, color: white),
                ),
                Text(
                  '${post.likeCount}',
                  style: context.text.bodyMedium?.copyWith(color: white),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    foregroundColor: white,
                    side: BorderSide(color: white.withValues(alpha: 0.8)),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onOpen,
                  icon: const Icon(LucideIcons.arrowUpRight, size: 18),
                  label: Text(l10n.storyViewPost),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty or failed circle: a short line on black, with Close.
class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onClose, this.onRetry});

  final String text;
  final VoidCallback onClose;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final white = context.palette.onBrandSurface;
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: IconButton(
              tooltip: context.l10n.storyClose,
              onPressed: onClose,
              icon: Icon(LucideIcons.x, color: white),
            ),
          ),
          Center(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: context.text.bodyLarge?.copyWith(color: white),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        foregroundColor: white,
                      ),
                      onPressed: onRetry,
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
