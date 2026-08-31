import 'dart:async';
import 'package:flutter/foundation.dart';

/// Adapts any [Stream] (here, AuthCubit's state stream) into a [Listenable]
/// so GoRouter re-runs its `redirect` callback whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
