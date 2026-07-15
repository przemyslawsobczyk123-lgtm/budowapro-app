abstract final class DatabaseValueCodec {
  static int dateTimeToUtcMilliseconds(DateTime value) {
    return value.toUtc().millisecondsSinceEpoch;
  }

  static DateTime utcMillisecondsToDateTime(int value) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
}
