import '../../core/l10n/generated/app_localizations.dart';

/// "now", "35m", "2h", "3d", then the date: the short times on posts and
/// comments in the designs.
String relativeTime(AppLocalizations l10n, DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time.toLocal());
  if (diff.inMinutes < 1) return l10n.timeNow;
  if (diff.inHours < 1) return l10n.timeMinutes(diff.inMinutes);
  if (diff.inDays < 1) return l10n.timeHours(diff.inHours);
  if (diff.inDays < 7) return l10n.timeDays(diff.inDays);
  final t = time.toLocal();
  return '${t.day}/${t.month}/${t.year}';
}
