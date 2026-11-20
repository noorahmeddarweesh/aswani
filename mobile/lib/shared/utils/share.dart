import 'package:share_plus/share_plus.dart';

/// Opens the phone's share sheet. Sharing is a nice-to-have, so a missing
/// share service (some desktops, tests) is ignored.
Future<void> shareText(String text) async {
  try {
    await SharePlus.instance.share(ShareParams(text: text));
  } on Object {
    // Nothing to do: the user simply sees no share sheet.
  }
}
