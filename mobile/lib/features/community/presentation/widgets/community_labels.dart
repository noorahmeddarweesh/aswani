import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/entities/post.dart';

extension PostCategoryLabel on PostCategory {
  String label(AppLocalizations l10n) => switch (this) {
    PostCategory.localExperience => l10n.communityCatLocalExperience,
    PostCategory.nubian => l10n.communityCatNubian,
    PostCategory.nile => l10n.communityCatNile,
    PostCategory.food => l10n.communityCatFood,
    PostCategory.other => l10n.communityCatOther,
  };
}
