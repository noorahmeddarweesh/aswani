import 'dart:typed_data';

import 'package:aswani/core/l10n/generated/app_localizations.dart';
import 'package:aswani/core/network/upload.dart';
import 'package:aswani/core/theme/app_theme.dart';
import 'package:aswani/shared/utils/relative_time.dart';
import 'package:aswani/shared/widgets/photo_picker_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('relative time: now, minutes, hours, days, then the date', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final now = DateTime(2026, 11, 20, 12);
    String at(Duration ago) => relativeTime(l10n, now.subtract(ago), now: now);
    expect(at(const Duration(seconds: 20)), 'now');
    expect(at(const Duration(minutes: 35)), '35m');
    expect(at(const Duration(hours: 2)), '2h');
    expect(at(const Duration(days: 3)), '3d');
    expect(at(const Duration(days: 30)), '21/10/2026');
  });

  testWidgets('photo field: pick, refuse a wrong type, remove', (tester) async {
    var photos = <UploadFile>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pickPhotosProvider.overrideWithValue(
            (max) async => [
              UploadFile(name: 'a.jpg', bytes: _png, path: '/a.jpg'),
              UploadFile(name: 'b.gif', bytes: _png, path: '/b.gif'),
            ],
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PhotoPickerField(
                photos: photos,
                title: 'Add your travel photos',
                buttonLabel: 'Choose photos',
                onChanged: (next) => setState(() => photos = next),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Choose photos'));
    await tester.pumpAndSettle();
    expect(photos.map((p) => p.name), ['a.jpg']);
    expect(find.text('Use a JPG, PNG or WEBP photo.'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove photo'));
    await tester.pumpAndSettle();
    expect(photos, isEmpty);
  });
}

// 1x1 transparent PNG.
final _png = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);
