import 'dart:io';

/// Abstract contract for checking device network connectivity.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Production implementation using a raw socket connection check.
/// Avoids adding `internet_connection_checker` as an extra dependency.
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on Exception {
      return false;
    }
  }
}
