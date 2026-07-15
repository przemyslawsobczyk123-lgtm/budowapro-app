import 'dart:collection';

final class PageRequest {
  PageRequest({int offset = 0, int limit = defaultLimit})
    : offset = _validOffset(offset),
      limit = _validLimit(limit);

  static const int defaultLimit = 50;
  static const int maximumLimit = 100;

  final int offset;
  final int limit;

  PageRequest next() => PageRequest(offset: offset + limit, limit: limit);

  static int _validOffset(int value) {
    if (value < 0) {
      throw RangeError.value(value, 'offset', 'must be zero or greater');
    }
    return value;
  }

  static int _validLimit(int value) {
    if (value < 1 || value > maximumLimit) {
      throw RangeError.range(value, 1, maximumLimit, 'limit');
    }
    return value;
  }

  @override
  bool operator ==(Object other) {
    return other is PageRequest &&
        other.offset == offset &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(offset, limit);
}

final class Page<T> {
  Page({
    required Iterable<T> items,
    required int totalCount,
    required this.request,
  }) : items = UnmodifiableListView<T>(items),
       totalCount = _validTotalCount(totalCount);

  final UnmodifiableListView<T> items;
  final int totalCount;
  final PageRequest request;

  bool get hasNext => request.offset + items.length < totalCount;

  PageRequest? get nextRequest => hasNext ? request.next() : null;

  static int _validTotalCount(int value) {
    if (value < 0) {
      throw RangeError.value(value, 'totalCount', 'must be zero or greater');
    }
    return value;
  }
}
