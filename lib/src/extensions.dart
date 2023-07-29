extension ListExt<T> on List<T> {
  T? elementAtOrNull(int index) => (index < length) ? this[index] : null;

  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
