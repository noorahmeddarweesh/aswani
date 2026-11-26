import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while the phone has a network (Wi-Fi, mobile data, ethernet...).
///
/// Note: being on a network does not guarantee internet access; requests
/// still handle `NO_CONNECTION` errors themselves.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);
  yield online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(online);
});
