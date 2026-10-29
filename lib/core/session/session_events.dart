import 'dart:async';

import 'package:injectable/injectable.dart';

/// Lets the network layer tell the rest of the app "the session is dead"
/// (refresh failed) without importing any feature code.
@lazySingleton
class SessionEvents {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onExpired => _controller.stream;

  void notifyExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }
}
