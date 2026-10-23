/// Backend success envelope is `{ "data": ..., "meta": {...} }`.
/// These helpers also tolerate a bare object so the app keeps working
/// while the contract is finalised with the backend developer.
Map<String, dynamic> unwrapData(dynamic body) {
  if (body is Map<String, dynamic>) {
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return body;
  }
  return <String, dynamic>{};
}

List<dynamic> unwrapList(dynamic body) {
  if (body is List) return body;
  if (body is Map<String, dynamic>) {
    final data = body['data'];
    if (data is List) return data;
  }
  return const [];
}
