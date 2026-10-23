/// Build-time configuration. Override with --dart-define:
///   flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1
abstract final class AppConfig {
  /// Default points to the Android emulator's host machine (dev backend).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // ── Obour City (مدينة العبور) ─────────────────────────────────────────────
  /// Map center used for pickers.
  static const double obourCenterLat = 30.2285;
  static const double obourCenterLng = 31.4770;

  /// Rough bounding box — a UX hint only. The backend validates the real
  /// service-area polygon and is the source of truth.
  static const double obourMinLat = 30.17;
  static const double obourMaxLat = 30.31;
  static const double obourMinLng = 31.40;
  static const double obourMaxLng = 31.57;

  static bool isInsideObourHint(double lat, double lng) =>
      lat >= obourMinLat &&
      lat <= obourMaxLat &&
      lng >= obourMinLng &&
      lng <= obourMaxLng;
}
