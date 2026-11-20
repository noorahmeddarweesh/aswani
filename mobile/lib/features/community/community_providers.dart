import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/session/session_controller.dart';
import 'data/datasources/community_datasource.dart';
import 'data/datasources/community_mock_datasource.dart';
import 'data/datasources/community_remote_datasource.dart';
import 'data/models/community_dtos.dart';
import 'data/repositories/community_repository_impl.dart';
import 'domain/repositories/community_repository.dart';

/// The only place that chooses mock or remote for Community:
/// `--dart-define=USE_MOCKS=false` switches to the API at `BASE_URL`.
final communityDataSourceProvider = Provider<CommunityDataSource>((ref) {
  if (!Env.useMocks) {
    return CommunityRemoteDataSource(ref.watch(apiClientProvider));
  }
  return CommunityMockDataSource(
    me: () {
      final session = ref.read(sessionProvider);
      return AuthorDto(
        id: session?.userId ?? 'u_1',
        fullName: session?.displayName ?? 'Laila Hassan',
        avatar: session?.avatarUrl,
      );
    },
  );
});

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => CommunityRepositoryImpl(ref.watch(communityDataSourceProvider)),
);
