import 'dart:typed_data';

import 'package:aswani/core/errors/failure.dart';
import 'package:aswani/core/network/upload.dart';
import 'package:aswani/core/result/result.dart';
import 'package:aswani/features/personalization/data/datasources/preferences_remote_datasource.dart';
import 'package:aswani/features/personalization/data/repositories/preferences_repository_impl.dart';
import 'package:aswani/features/personalization/domain/entities/preferences.dart';
import 'package:aswani/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:aswani/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:aswani/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:aswani/features/profile/domain/entities/profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_api.dart';

T ok<T>(Result<T> r) => (r as Success<T>).value;

void main() {
  group('remote (contract v0.2, Profile & Settings)', () {
    test('profile: stats, 3 saved photos, contribution rows', () async {
      final api = FakeApi(
        (_) => reply(200, {
          'data': {
            'id': 'u_9',
            'full_name': 'Omar',
            'avatar': null,
            'persona': 'resident',
            'city': null,
            'bio': null,
            'stats': {
              'saved_places': 1,
              'saved_stories': 2,
              'posts': 3,
              'points': 50,
            },
            'saved_preview': [
              {'type': 'story', 'id': 's1', 'image': 'https://x/1.jpg'},
              {'type': 'video', 'id': 'v1', 'image': 'https://x/v.jpg'},
            ],
            'contributions': {
              'reports_under_review': 0,
              'added_activities': 4,
              'guide_requests_pending': 2,
            },
          },
        }),
      );
      final repo = ProfileRepositoryImpl(ProfileRemoteDataSource(api.client()));
      final p = ok(await repo.getProfile());
      expect(api.requests.single.path, '/users/me/profile');
      expect(p.avatar, isNull);
      expect(p.stats.points, 50);
      expect(p.savedPreview.single.type, SavedType.story);
      expect(p.contributions.addedActivities, 4);
    });

    test('saved list reads places and stories, drops unknown types', () async {
      final api = FakeApi(
        (_) => reply(200, {
          'data': [
            {
              'type': 'place',
              'place': {
                'id': 'philae',
                'name_en': 'Philae',
                'name_ar': 'فيلة',
                'image': 'https://x/p.jpg',
              },
            },
            {
              'type': 'story',
              'story': {
                'id': 's1',
                'title_en': 'Homes',
                'title_ar': 'بيوت',
                'label_en': 'Nubian heritage',
                'label_ar': 'تراث نوبي',
                'cover_image': 'https://x/s.jpg',
              },
            },
            {'type': 'event', 'event': <String, dynamic>{}},
          ],
          'meta': {'page': 1, 'limit': 20, 'total': 3, 'total_pages': 1},
        }),
      );
      final repo = ProfileRepositoryImpl(ProfileRemoteDataSource(api.client()));
      final page = ok(await repo.getSaved(type: SavedType.story));
      expect(api.requests.single.queryParameters, {
        'type': 'story',
        'page': 1,
        'limit': 20,
      });
      expect(page.items.map((e) => e.id), ['philae', 's1']);
      expect(page.items.last.title('ar'), 'بيوت');
    });

    test('settings PATCH sends only what changed', () async {
      final api = FakeApi(
        (_) => reply(200, {
          'data': {'language': 'ar', 'notifications_enabled': false},
        }),
      );
      final repo = ProfileRepositoryImpl(ProfileRemoteDataSource(api.client()));
      final s = ok(await repo.updateSettings(languageCode: 'ar'));
      expect(api.requests.single.method, 'PATCH');
      expect(api.requests.single.data, {'language': 'ar'});
      expect(s.notificationsEnabled, isFalse);
    });

    test('avatar is PUT as multipart "avatar"', () async {
      final api = FakeApi(
        (_) => reply(200, {
          'data': {'avatar': 'https://x/me.jpg'},
        }),
      );
      final repo = ProfileRepositoryImpl(ProfileRemoteDataSource(api.client()));
      final url = ok(
        await repo.uploadAvatar(
          UploadFile(name: 'me.jpg', bytes: Uint8List(4), path: '/me.jpg'),
        ),
      );
      expect(url, 'https://x/me.jpg');
      expect(api.requests.single.method, 'PUT');
      expect((api.requests.single.data as FormData).files.single.key, 'avatar');
    });

    test(
      'deletion request: 202, then 409 DELETION_ALREADY_REQUESTED',
      () async {
        var calls = 0;
        final api = FakeApi(
          (_) => calls++ == 0
              ? reply(202, {
                  'data': {'status': 'requested'},
                })
              : reply(409, apiError(ErrorCodes.deletionAlreadyRequested)),
        );
        final repo = ProfileRepositoryImpl(
          ProfileRemoteDataSource(api.client()),
        );
        expect(await repo.requestDeletion(), isA<Success<void>>());
        final second = await repo.requestDeletion();
        expect(
          (second as Error).failure.code,
          ErrorCodes.deletionAlreadyRequested,
        );
        expect(api.requests.first.path, '/users/me/deletion-request');
      },
    );

    test('preferences GET reads the v0.2 {data} body', () async {
      final api = FakeApi(
        (_) => reply(200, {
          'data': {
            'persona': 'visitor',
            'purpose': 'tourism',
            'stay_length': 'few_days',
            'interests': ['nubian', 'traditional_food', 'unknown'],
            'travel_styles': ['hidden'],
            'companions': 'may_change',
            'needs': ['local_guides'],
            'language': 'ar',
          },
        }),
      );
      final repo = PreferencesRepositoryImpl(
        PreferencesRemoteDataSource(api.client()),
      );
      final p = ok(await repo.load())!;
      expect(api.requests.single.path, '/users/preferences');
      expect(p.persona, Persona.visitor);
      expect(p.stayLength, StayLength.fewDays);
      expect(p.interests, {Interest.nubian, Interest.traditionalFood});
      expect(p.companions, Companions.mayChange);
      expect(p.languageCode, 'ar');
    });
  });

  test('mock rejects a photo that is too big', () async {
    final repo = ProfileRepositoryImpl(
      ProfileMockDataSource(delay: Duration.zero),
    );
    final r = await repo.uploadAvatar(
      UploadFile(
        name: 'big.png',
        bytes: Uint8List(UploadRules.maxBytes + 1),
        path: '/big.png',
      ),
    );
    final failure = (r as Error).failure;
    expect(failure.code, ErrorCodes.validation);
    expect(failure.fieldErrors['avatar'], ErrorCodes.fileTooLarge);
  });
}
