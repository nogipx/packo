import 'dart:io';

import 'package:packo/packo.dart';
import 'package:process_run/shell.dart';

class Entrypoint {
  final Directory _workdir;
  final bool useFvm;

  Directory get workdir => _workdir;

  Entrypoint(
    Directory? workdir, {
    this.useFvm = false,
  }) : _workdir = workdir ?? Directory.current;

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
    bool withRootPackage = true,
  }) {
    final packagesDirs = getSubDirectories(recursive: recursive);
    final targetDirs = [
      ...packagesDirs,
      if (withRootPackage) workdir,
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

  Future<void> startBuildRunner({
    required String flutterExecutable,
    required Package package,
  }) async {
    _guardEntrypointContainsPackage(package);

    if (!package.containsDependency('build_runner')) {
      print(
        'Skip "${package.name}" generation cause "build_runner" '
        'dependency not registered by this package.\n\n',
      );
    }

    final controller = ShellLinesController();
    final listen = controller.stream.listen(print);

    final shell = Shell(
      workingDirectory: workdir.path,
      stdout: controller.sink,
    );

    print('\n[${package.name}] build_runner started.');

    await shell.run(
      '$flutterExecutable pub get',
    );

    await shell.run(
      '$flutterExecutable pub run build_runner build --delete-conflicting-outputs',
    );

    controller.close();
    await listen.cancel();
  }

  Future<void> startPubGet({
    required String flutterExecutable,
    required Package package,
  }) async {
    _guardEntrypointContainsPackage(package);

    final controller = ShellLinesController();
    final listen = controller.stream.listen(print);

    final shell = Shell(
      workingDirectory: workdir.path,
      stdout: controller.sink,
    );

    print('\n[${package.name}] pub get started.');

    await shell.run(
      '$flutterExecutable pub get',
    );

    controller.close();
    await listen.cancel();
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
