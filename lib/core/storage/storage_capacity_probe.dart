import 'dart:io';

import 'package:flutter/services.dart';

abstract interface class StorageCapacityProbe {
  Future<int> availableBytes(Directory directory);
}

final class PlatformStorageCapacityProbe implements StorageCapacityProbe {
  const PlatformStorageCapacityProbe();

  static const MethodChannel _channel = MethodChannel('pl.budowapro/storage');

  @override
  Future<int> availableBytes(Directory directory) async {
    final result = await _channel.invokeMethod<int>(
      'availableBytes',
      <String, Object?>{'path': directory.absolute.path},
    );
    if (result == null || result < 0) {
      throw const FileSystemException('Available storage could not be read');
    }
    return result;
  }
}
