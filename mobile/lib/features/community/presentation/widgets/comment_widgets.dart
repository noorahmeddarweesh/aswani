import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/utils/relative_time.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../domain/entities/post.dart';

/// One comment: photo, name, text and time. Long press (or the bin) deletes
/// the user's own comment.
class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment, this.onDelete});

  final Comment comment;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onDelete,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              name: comment.author.fullName,
              imageUrl: comment.author.avatarUrl,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.author.fullName,
                    style: context.text.bodySmall?.copyWith(
                      fontSize: 12,
                      color: context.palette.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    comment.text,
                    style: context.text.bodyMedium?.copyWith(fontSize: 13),
                  ),
                  Text(
                    relativeTime(context.l10n, comment.createdAt),
                    style: context.text.labelSmall?.copyWith(
                      color: context.palette.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: context.l10n.communityDeleteComment,
                icon: Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: context.palette.textTertiary,
                ),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

/// The comment box: the user's photo, the field and Send.
class CommentComposer extends StatefulWidget {
  const CommentComposer({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.sending,
    required this.onSend,
    this.focusNode,
    this.quickEmojis = false,
    this.topBorder = true,
  });

  final String name;
  final String? avatarUrl;
  final bool sending;
  final FocusNode? focusNode;

  /// A row of emojis above the box, as in Instagram's comments.
  final bool quickEmojis;
  final bool topBorder;

  static const emojis = ['❤️', '🙌', '🔥', '👏', '😍', '😮', '😂', '🌅'];

  /// Returns true when the comment was posted (the box is then cleared).
  final Future<bool> Function(String text) onSend;

  @override
  State<CommentComposer> createState() => CommentComposerState();
}

class CommentComposerState extends State<CommentComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addEmoji(String emoji) {
    final value = _controller.value;
    final sel = value.selection;
    final at = sel.isValid ? sel.start : value.text.length;
    final end = sel.isValid ? sel.end : value.text.length;
    _controller.value = TextEditingValue(
      text: value.text.replaceRange(at, end, emoji),
      selection: TextSelection.collapsed(offset: at + emoji.length),
    );
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty || widget.sending) return;
    if (await widget.onSend(text)) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.5,
      child: Material(
        color: context.colors.surface,
        child: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              border: widget.topBorder
                  ? Border(top: BorderSide(color: palette.border))
                  : null,
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.quickEmojis)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (final e in CommentComposer.emojis)
                          InkResponse(
                            radius: 22,
                            onTap: () => _addEmoji(e),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    UserAvatar(
                      name: widget.name,
                      imageUrl: widget.avatarUrl,
                      size: 36,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: widget.focusNode,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 1000,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: context.l10n.communityCommentHint,
                          counterText: '',
                          isDense: true,
                          border: const OutlineInputBorder(
                            borderRadius: AppRadii.pillAll,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        final ready =
                            _controller.text.trim().isNotEmpty &&
                            !widget.sending;
                        return IconButton.filled(
                          tooltip: context.l10n.communitySendComment,
                          onPressed: ready ? _send : null,
                          icon: widget.sending
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  LucideIcons.sendHorizontal,
                                  size: 18,
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
