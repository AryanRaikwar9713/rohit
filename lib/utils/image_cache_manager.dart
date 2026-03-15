import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/io_client.dart';

/// Cache manager with extended timeout (30s) to avoid SocketException
/// when loading images from slow servers (e.g. wamims.international).
class ExtendedTimeoutCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'extendedTimeoutImages';
  static const timeoutSeconds = 30;

  static final ExtendedTimeoutCacheManager _instance =
      ExtendedTimeoutCacheManager._();
  factory ExtendedTimeoutCacheManager() => _instance;

  ExtendedTimeoutCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 300,
            fileService: HttpFileService(
              httpClient: IOClient(
                HttpClient()
                  ..connectionTimeout = const Duration(seconds: timeoutSeconds)
                  ..idleTimeout = const Duration(seconds: timeoutSeconds),
              ),
            ),
          ),
        );
}
