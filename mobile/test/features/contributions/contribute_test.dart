import 'dart:async';
import 'dart:typed_data';

import 'package:aswani/core/network/upload.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/core/router/app_router.dart';
import 'package:aswani/core/session/session_controller.dart';
import 'package:aswani/features/contributions/data/datasources/contributions_remote_datasource.dart';
import 'package:aswani/features/contributions/data/repositories/contributions_repository_impl.dart';
import 'package:aswani/features/contributions/domain/entities/contribution.dart';
import 'package:aswani/features/contributions/presentation/viewmodels/contribute_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/pump_app.dart';

void main() {
  test('form rules: required fields and an Egyptian mobile number', () {
    final container = ProviderContainer(overrides: fastMocks());
    addTearDown(container.dispose);
    final sub = container.listen(contributeProvider, (_, _) {});
    addTearDown(sub.close);
    final vm = container.read(contributeProvider.notifier)
      ..start(ContributionCategory.cafe);

    expect(vm.review(), isFalse);
    final state = container.read(contributeProvider);
    expect(state.error(ContributeField.name), isTrue);
    expect(state.error(ContributeField.description), isTrue);
    expect(state.error(ContributeField.address), isTrue);
    expect(state.error(ContributeField.contact), isFalse);

    vm
      ..setName('Nile View')
      ..setDescription('Tea by the river')
      ..setAddress('Corniche')
      ..setContact('0101234');
    expect(vm.review(), isFalse);
    vm.setContact('010 1234 5678');
    expect(vm.review(), isTrue);
  });

  test('remote: multipart with "photos", contact number optional', () async {
    final api = FakeApi(
      (r) => r.method == 'POST'
          ? reply(201, {
              'data': {'id': 'k9', 'status': 'pending'},
            })
          : reply(200, {
              'data': [
                {
                  'id': 'k9',
                  'category': 'clinic',
                  'name': 'Dr. Aly',
                  'status': 'pending',
                  'points_awarded': 0,
                  'created_at': '2026-11-20T10:00:00Z',
                },
              ],
              'meta': {'page': 1, 'limit': 20, 'total': 1, 'total_pages': 1},
            }),
    );
    final repo = ContributionsRepositoryImpl(
      ContributionsRemoteDataSource(api.client()),
    );
    final id = await repo.submit(
      const ContributionDraft(
        category: ContributionCategory.clinic,
        name: 'Dr. Aly',
        description: 'Family clinic',
        address: 'Kima',
      ),
      [UploadFile(name: 'a.png', bytes: Uint8List(3), path: '/a.png')],
    );
    expect((id as Success<String>).value, 'k9');
    final form = api.requests.first.data as FormData;
    expect(form.files.single.key, 'photos');
    expect(form.fields.map((f) => f.key), [
      'category',
      'name',
      'description',
      'address',
    ]);
    final mine = await repo.getMine();
    expect(
      (mine as Success).value.items.single.status,
      ContributionStatus.pending,
    );
  });

  testWidgets('category, details, preview, then Contribution received', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    container
        .read(sessionProvider.notifier)
        .signedIn(
          const Session(userId: 'u_1', displayName: 'L', hasPreferences: true),
        );
    await tester.pumpAndSettle();
    final router = container.read(appRouterProvider);
    unawaited(router.push('/contribute'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Café'));
    await tester.pumpAndSettle();
    expect(find.text('Activity details'), findsOneWidget);
    expect(find.text('Café'), findsOneWidget);

    await tester.ensureVisible(find.text('Preview & submit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview & submit'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the name (at least 2 letters).'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Nile View Café');
    await tester.enterText(fields.at(1), 'Hibiscus tea by the river');
    await tester.enterText(fields.at(2), 'Corniche, near the ferry');
    await tester.pump();
    await tester.ensureVisible(find.text('Preview & submit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview & submit'));
    await tester.pumpAndSettle();
    expect(find.text('Hibiscus tea by the river'), findsOneWidget);

    await tester.tap(find.text('Submit contribution'));
    await tester.pumpAndSettle();
    expect(find.text('Contribution received'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Back to home'));
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, '/home');
  });

  test(
    'edit: get one, send changes, back to pending (contract v0.3)',
    () async {
      final api = FakeApi(
        (r) => switch ((r.method, r.path)) {
          ('GET', '/contributions/k1') => reply(200, {
            'data': {
              'id': 'k1',
              'category': 'cafe',
              'name': 'Nile View',
              'description': 'Tea',
              'address': 'Corniche',
              'contact_number': null,
              'photos': ['https://x/1.jpg', 'https://x/2.jpg'],
              'status': 'accepted',
              'points_awarded': 25,
              'created_at': '2026-11-01T10:00:00Z',
              'updated_at': '2026-11-01T10:00:00Z',
            },
          }),
          ('PATCH', '/contributions/k1') => reply(200, {
            'data': {'id': 'k1', 'status': 'pending'},
          }),
          _ => reply(404, apiError('CONTRIBUTION_NOT_FOUND')),
        },
      );
      final repo = ContributionsRepositoryImpl(
        ContributionsRemoteDataSource(api.client()),
      );
      final one =
          (await repo.getOne('k1') as Success<ContributionDetails>).value;
      expect(one.photos, hasLength(2));
      expect(one.status, ContributionStatus.accepted);

      await repo.update(
        'k1',
        one.draft,
        keepPhotos: [one.photos.first],
        photos: [
          UploadFile(name: 'n.png', bytes: Uint8List(3), path: '/n.png'),
        ],
      );
      final form = api.requests.last.data as FormData;
      expect(api.requests.last.method, 'PATCH');
      expect(
        form.fields.where((f) => f.key == 'keep_photos').map((f) => f.value),
        ['https://x/1.jpg'],
      );
      expect(form.files.single.key, 'photos');

      final missing = await repo.getOne('nope');
      expect((missing as Error).failure.code, 'CONTRIBUTION_NOT_FOUND');
    },
  );

  testWidgets('Added activities > Edit: filled form, changes go to review', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    container
        .read(sessionProvider.notifier)
        .signedIn(
          const Session(userId: 'u_1', displayName: 'L', hasPreferences: true),
        );
    await tester.pumpAndSettle();
    final router = container.read(appRouterProvider);
    unawaited(router.push('/contribute/mine'));
    await tester.pumpAndSettle();
    expect(find.text('Published'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit activity'), findsOneWidget);
    expect(find.text('Nile View Café'), findsOneWidget);
    expect(find.text('Current photos'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Nile View Terrace');
    await tester.tap(find.byTooltip('Remove photo'));
    await tester.pump();
    await tester.ensureVisible(find.text('Preview & submit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview & submit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send changes'));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, '/contribute/mine');
    expect(
      find.text('Changes sent. Your activity is under review again.'),
      findsOneWidget,
    );
    expect(find.text('Nile View Terrace'), findsOneWidget);
    expect(find.text('Published'), findsNothing);
    expect(find.text('Under review'), findsOneWidget);
  });
}
