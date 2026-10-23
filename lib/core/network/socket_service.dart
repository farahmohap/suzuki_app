import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/app_config.dart';
import '../storage/token_storage.dart';

/// Thin wrapper around socket.io-client (used from phase 3: live tracking).
/// Phase 0 only provides connect / reconnect / typed event streams.
@lazySingleton
class SocketService {
  SocketService(this._tokens);

  final TokenStorage _tokens;
  io.Socket? _socket;
  final _connected = StreamController<bool>.broadcast();

  Stream<bool> get connection => _connected.stream;
  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    final token = await _tokens.readAccess();
    if (token == null || token.isEmpty) return;

    _socket?.dispose();
    final socket = io.io(
      AppConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .disableAutoConnect()
          .build(),
    );
    socket.onConnect((_) => _connected.add(true));
    socket.onDisconnect((_) => _connected.add(false));
    socket.connect();
    _socket = socket;
  }

  /// Subscribes to [event]; the stream ends when [disconnect] is called.
  Stream<dynamic> on(String event) {
    final controller = StreamController<dynamic>.broadcast();
    _socket?.on(event, controller.add);
    return controller.stream;
  }

  void emit(String event, [dynamic data]) => _socket?.emit(event, data);

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _connected.add(false);
  }
}
