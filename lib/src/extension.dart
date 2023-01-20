import '_index.dart';

extension UriExt on Uri {
  String get lastPathSegment {
    final segments = pathSegments;
    return pathSegments.length >= 2 ? segments[segments.length - 2] : '';
  }
}

extension PackagesIterable on Iterable<Package> {
  List<Version> get versions => map((e) => e.version).toList();

  List<Package> get excludeSync =>
      where((e) => !excludePackages.contains(e.name)).toList();

  bool get allVersionsSynced {
    try {
      versions.reduce(
          (current, next) => current == next ? next : throw Exception());
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Version? get maxVersion {
    final versions = this.versions;
    if (versions.isNotEmpty) {
      return versions.fold<Version>(
        Version(0, 0, 0),
        (max, e) => e > max ? e : max,
      );
    }
    return null;
  }

  Version? get minVersion {
    final versions = this.versions;
    if (versions.isNotEmpty) {
      return versions.fold<Version>(
        versions.first,
        (min, e) => e < min ? e : min,
      );
    }
    return null;
  }

  Package? find({required String name}) {
    final match = where((e) => e.name == name);
    return match.isNotEmpty ? match.first : null;
  }
}
