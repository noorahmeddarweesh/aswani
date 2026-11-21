import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../shared/extensions/context_x.dart';
import '../../../../shared/utils/share.dart';
import '../../../../shared/widgets/confirm_sheet.dart';
import '../../domain/entities/post.dart';

/// Small helpers shared by the community screens.
abstract final class PostUi {
  static void showError(BuildContext context, String? code) {
    if (code == null || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.errorFor(code))));
  }

  /// Waits for [action] and shows its error, if any.
  static Future<void> report(
    BuildContext context,
    Future<String?> action,
  ) async {
    final code = await action;
    if (context.mounted) showError(context, code);
  }

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> share(BuildContext context, Post post) =>
      shareText(context.l10n.communityShareText(post.caption));

  static Future<bool> confirmDeletePost(BuildContext context) =>
      showConfirmSheet(
        context,
        title: context.l10n.communityDeletePostTitle,
        message: context.l10n.communityDeletePostBody,
        confirmLabel: context.l10n.delete,
        icon: LucideIcons.trash2,
        destructive: true,
      );

  static Future<bool> confirmDeleteComment(BuildContext context) =>
      showConfirmSheet(
        context,
        title: context.l10n.communityDeleteCommentTitle,
        message: context.l10n.communityDeleteCommentBody,
        confirmLabel: context.l10n.delete,
        icon: LucideIcons.trash2,
        destructive: true,
      );
}
