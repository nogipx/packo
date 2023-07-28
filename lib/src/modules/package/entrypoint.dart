import 'dart:io';

import 'package:packo/packo.dart';

class Entrypoint {
  final Directory _workdir;
  Directory get workdir => _workdir;

  Entrypoint(Directory? workdir) : _workdir = workdir ?? Directory.current;

  Iterable<Directory> getSubDirectories({
    bool recursive = true,
  }) {
    final featurePackagesPath = _workdir
        .listSync(recursive: recursive)
        .whereType<Directory>()
        .where((e) {
      final isDartTool = e.path.contains('.dart_tool');
      final isSdk =
          e.path.contains('flutter_sdk') || e.path.contains('ios/.symlinks');
      final isHiddenDirectory = _lastPathSegment(e.uri).startsWith('.');

      return !isSdk && !isDartTool && !isHiddenDirectory;
    });

    return featurePackagesPath;
  }

  String _lastPathSegment(Uri data) {
    final segments = data.pathSegments;
    return data.pathSegments.length >= 2 ? segments[segments.length - 2] : '';
  }

  Package? get currentPackage {
    return Package.of(_workdir);
  }

  Future<bool> containsPubspec() async {
    final file = File('${_workdir.path}/pubspec.yaml');
    if (file.existsSync()) {
      return true;
    } else {
      final shortFile = File('${_workdir.path}/pubspec.yml');
      if (shortFile.existsSync()) {
        return true;
      }
      return false;
    }
  }

  PackagesCollection getPackages({
    bool recursive = true,
  }) {
    final packagesDirs = getSubDirectories(recursive: recursive);
    final targetDirs = [
      ...packagesDirs,
      workdir,
    ];
    final packages = targetDirs.map(Package.of).whereType<Package>().toList();
    final collection = PackagesCollection(
      packages: packages,
    );

    return collection;
  }

  void incrementMajor(Package package) {
    _setVersion(
      package: package,
      version: package.version.incrementMajor(),
    );
  }

  void incrementMinor(Package package) {
    _setVersion(
      package: package,
      version: package.version.incrementMinor(),
    );
  }

  void incrementPatch(Package package) {
    _setVersion(
      package: package,
      version: package.version.incrementPatch(),
    );
  }

  void incrementBuildNumber(Package package) {
    final current = package.version;
    final buildVersion = int.tryParse(current.build);

    final newVersion = Version(
      current.major,
      current.minor,
      current.patch,
      build: buildVersion != null ? (buildVersion + 1).toString() : '',
    );

    _setVersion(package: package, version: newVersion);
  }

  void _setVersion({
    required Package package,
    required Version version,
  }) {
    _guardEntrypointContainsPackage(package);

    final pubspec = package.pubspec;
    final pubspecContent = pubspec.readAsStringSync();
    final edited = pubspecContent.replaceFirst(
      'version: ${package.version}',
      'version: $version',
    );
    pubspec.writeAsStringSync(edited);
  }

  Future<void> startBuildRunner(Package package) async {
    _guardEntrypointContainsPackage(package);
  }

  void _guardEntrypointContainsPackage(Package package) {
    final collection = getPackages();
    final found = collection.find(name: package.name);
    if (found == null) {
      throw Exception(
        'Cannot perform action to package outbound current entrypoint',
      );
    }
  }
}
