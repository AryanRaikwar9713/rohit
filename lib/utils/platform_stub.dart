/// Stub for web – no dart:io. Use with: import 'dart:io' if (dart.library.io) 'utils/platform_stub.dart' as io;
class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static String get operatingSystem => 'web';
}

/// Stub for web – HTTP header names (dart:io HttpHeaders constants).
class HttpHeaders {
  static const String cacheControlHeader = 'cache-control';
  static const String acceptHeader = 'accept';
  static const String contentTypeHeader = 'content-type';
  static const String authorizationHeader = 'authorization';
}

/// Stub so that `e is io.SocketException` is valid on web (never true there).
class SocketException implements Exception {
  SocketException();
}

/// Stub for web – multipart uploads use bytes instead of path.
class File {
  File([String? path]) : _path = path ?? '';
  final String _path;
  String get path => _path;
}

/// Stub for web – path_provider compatibility.
class Directory {
  Directory([String? path]) : _path = path ?? '';
  final String _path;
  String get path => _path;
}
